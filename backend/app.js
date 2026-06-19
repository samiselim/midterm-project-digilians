const express = require('express');
const path = require('path');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const logger = require('./middleware/logger');
const { sequelize } = require('./models');

const app = express();
const port = process.env.PORT || 8000;

app.use(express.json());
app.use(cors());
app.use(logger);

// Health check endpoint for ALB target group
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', timestamp: new Date() });
});

const leaveRoutes = require("./routes/leaveRoutes");
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");

app.use('/api/leaves', leaveRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// Sync database and start server
sequelize.sync({ alter: true })
  .then(() => {
    app.listen(port, () => {
      console.log(`Server running on port ${port}`);
    });
  })
  .catch(err => {
    console.error('Database synchronization failed:', err);
  });