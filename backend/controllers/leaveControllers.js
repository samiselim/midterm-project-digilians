const { LeaveRequest, User } = require("../models");
const Joi = require("joi");
const { Op } = require("sequelize");

const submitLeaveSchema = Joi.object({
  type: Joi.string().optional(),
  startDate: Joi.date().iso().required(),
  endDate: Joi.date().iso().min(Joi.ref('startDate')).required()
    .messages({ 'date.min': 'End date cannot be before start date' }),
  reason: Joi.string().when('type', {
    is: 'Other',
    then: Joi.string().required(),
    otherwise: Joi.string().allow('', null).optional()
  })
}).unknown(true);

const reviewLeaveSchema = Joi.object({
  requestId: Joi.string().required(),
  status: Joi.string().valid('Approved', 'Rejected').required()
}).unknown(true);

const submitLeave = async (req, res) => {
  try {
    const { error, value } = submitLeaveSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ msg: error.details[0].message });
    }

    const { type, startDate, endDate, reason } = value;
    const employeeId = req.user.id;

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start < new Date().setHours(0,0,0,0))
      return res.status(400).json({ msg: "Cannot request leave in the past" });

    if (end < start)
      return res.status(400).json({ msg: "End date cannot be before start date" });

    let totalDays = 0;
    let currentDate = new Date(start);
    currentDate.setHours(0, 0, 0, 0);
    const endDateObj = new Date(end);
    endDateObj.setHours(0, 0, 0, 0);

    while (currentDate <= endDateObj) {
      const dayOfWeek = currentDate.getDay();
      if (dayOfWeek !== 5 && dayOfWeek !== 6) { // 5=Friday, 6=Saturday
        totalDays++;
      }
      currentDate.setDate(currentDate.getDate() + 1);
    }

    if (totalDays === 0) {
      return res.status(400).json({ msg: "Leave request must include at least one working day" });
    }

    // Check for overlapping leave requests that are not rejected or cancelled
    const overlap = await LeaveRequest.findOne({
      where: {
        employeeId,
        status: { [Op.notIn]: ["Rejected", "Cancelled"] },
        [Op.or]: [
          {
            startDate: { [Op.lte]: endDate },
            endDate: { [Op.gte]: startDate }
          }
        ]
      }
    });

    if (overlap)
      return res.status(400).json({ msg: "Overlapping leave request" });

    const user = await User.findByPk(employeeId);

    if (user.leaveBalance < totalDays)
      return res.status(400).json({ msg: "Insufficient leave balance" });

    const request = await LeaveRequest.create({
      employeeId,
      type: type || "Annual",
      startDate,
      endDate,
      totalDays,
      reason
    });

    res.status(201).json({
      msg: "Leave request submitted",
      request
    });

  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
};

const reviewLeave = async (req, res) => {
  try {
    const { error, value } = reviewLeaveSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ msg: error.details[0].message });
    }

    const { requestId, status } = value;

    const request = await LeaveRequest.findByPk(requestId);

    if (!request)
      return res.status(404).json({ msg: "Request not found" });

    const oldStatus = request.status;

    if (oldStatus === status) {
        return res.status(400).json({ msg: `Request is already ${status.toLowerCase()}` });
    }

    const employee = await User.findByPk(request.employeeId);

    if (req.user.role === "manager") {
      if (!employee.managerId || employee.managerId !== req.user.id) {
        return res.status(403).json({ msg: "You can only review your team's requests" });
      }
    }

    // Only "Annual", "Personal", and "Other" deduct from balance. "Sick" and "Unpaid" are exempt.
    const isPaidLeave = !["Sick", "Unpaid"].includes(request.type);

    if (isPaidLeave) {
        if (status === "Approved") {
            // New approval: Check and deduct
            if (employee.leaveBalance < request.totalDays) {
                return res.status(400).json({ msg: "Insufficient leave balance" });
            }
            employee.leaveBalance -= request.totalDays;
        } else if (oldStatus === "Approved") {
            // Changing from Approved to something else: Refund balance
            employee.leaveBalance += request.totalDays;
        }
        await employee.save();
    }

    request.status = status;
    request.reviewedBy = req.user.id;
    request.reviewedAt = new Date();

    await request.save();

    res.json({ msg: `Request ${status}`, currentBalance: isPaidLeave ? employee.leaveBalance : undefined });

  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
};

const getMyLeaves = async (req, res) => {
  try {
    const leaves = await LeaveRequest.findAll({
      where: { employeeId: req.user.id },
      order: [["createdAt", "DESC"]]
    });

    res.json(leaves);

  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
};

const cancelLeave = async (req, res) => {
  try {
    const request = await LeaveRequest.findOne({
      where: {
        _id: req.params.id,
        employeeId: req.user.id
      }
    });

    if (!request) return res.status(404).json({ msg: "Request not found" });

    if (request.status !== "Pending") {
      return res.status(400).json({ msg: "Only pending requests can be cancelled" });
    }

    request.status = "Cancelled";
    await request.save();

    res.json({ msg: "Leave cancelled", request });
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
};

const getTeamLeaves = async (req, res) => {
  try {
    let query = {};
    if (req.user.role !== 'admin') {
      const teamMembers = await User.findAll({
        where: { managerId: req.user.id },
        attributes: ["_id"]
      });
      const memberIds = teamMembers.map(member => member._id);
      query = { employeeId: { [Op.in]: memberIds } };
    }

    const leaves = await LeaveRequest.findAll({
      where: query,
      include: [{
        model: User,
        as: "employee",
        attributes: ["_id", "username", "email", "leaveBalance"]
      }],
      order: [["createdAt", "DESC"]]
    });

    // Map the 'employee' association to the 'employeeId' key to match MongoDB populated schema output
    const mappedLeaves = leaves.map(l => {
      const json = l.toJSON();
      json.employeeId = json.employee;
      delete json.employee;
      return json;
    });

    res.json(mappedLeaves);
  } catch (err) {
    res.status(500).json({ msg: err.message });
  }
};

module.exports = {
  submitLeave,
  reviewLeave,
  getMyLeaves,
  cancelLeave,
  getTeamLeaves
};