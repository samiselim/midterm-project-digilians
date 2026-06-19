const sequelize = require('../config/database');
const User = require('./User');
const LeaveRequest = require('./LeaveRequest');

// User self-referential association for Manager relationship
User.belongsTo(User, { foreignKey: 'managerId', as: 'manager' });
User.hasMany(User, { foreignKey: 'managerId', as: 'subordinates' });

// User <-> LeaveRequest associations
// We alias the belongsTo association as 'employeeId' to preserve the output key format 
// of the original Mongoose '.populate("employeeId")' queries in the frontend.
LeaveRequest.belongsTo(User, { foreignKey: 'employeeId', as: 'employee' });
User.hasMany(LeaveRequest, { foreignKey: 'employeeId', as: 'leaves' });

// Association for reviewer
LeaveRequest.belongsTo(User, { foreignKey: 'reviewedBy', as: 'reviewer' });
User.hasMany(LeaveRequest, { foreignKey: 'reviewedBy', as: 'reviewedLeaves' });

module.exports = {
  sequelize,
  User,
  LeaveRequest
};
