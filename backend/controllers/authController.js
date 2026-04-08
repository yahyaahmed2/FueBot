const { findUserByEmailWithPassword, verifyPassword, findUserByEmail } = require('../models/userModel');
const db = require('../config/config');
const bcrypt = require('bcryptjs');

exports.register = async (req, res) => {
  try {
    const { firstName, lastName, email, password, major, gpa } = req.body;

    // Input validation
    if (!firstName || !lastName || !email || !password || !major) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters' });
    }

    // Check if user already exists
    const existingUser = await findUserByEmailWithPassword(email);
    if (existingUser) {
      return res.status(409).json({ message: 'User with this email already exists' });
    }

    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Insert new user
    const result = await db.query(
      'INSERT INTO student (first_name, last_name, email, password, gpa, major) VALUES ($1, $2, $3, $4, $5, $6) RETURNING student_id',
      [firstName, lastName, email, hashedPassword, gpa || null, major]
    );

    res.status(201).json({
      message: 'User registered successfully',
      userId: result.rows[0].student_id
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Input validation
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    // Find user by email
    const user = await findUserByEmailWithPassword(email);
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Verify password
    const isValidPassword = await verifyPassword(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const sessionUser = await findUserByEmail(email);
    // Set session
    req.session.userId = sessionUser.student_id;
    req.session.userEmail = sessionUser.email;
    req.session.userName = `${sessionUser.first_name} ${sessionUser.last_name}`;

    res.json({
      message: 'Logged in successfully',
      user: {
        id: sessionUser.student_id,
        email: sessionUser.email,
        name: `${sessionUser.first_name} ${sessionUser.last_name}`,
        major: sessionUser.major
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.logout = (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      console.error('Logout error:', err);
      return res.status(500).json({ message: 'Could not log out' });
    }
    res.clearCookie('connect.sid');
    res.json({ message: 'Logged out successfully' });
  });
};

exports.dashboard = (req, res) => {
  res.json({
    message: 'Welcome to dashboard',
    user: req.user
  });
};