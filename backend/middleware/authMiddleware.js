const { findUserByEmail } = require('../models/userModel');

const requireAuth = async (req, res, next) => {
  try {
    if (!req.session.userId) {
      return res.status(401).json({ message: 'Unauthorized - Please log in' });
    }

    // Optional: Fetch fresh user data from database
    // This ensures user data is current even if session is old
    const user = await findUserByEmail(req.session.userEmail);
    if (!user) {
      req.session.destroy();
      return res.status(401).json({ message: 'User not found - Please log in again' });
    }

    // Attach user to request for easy access in controllers
    req.user = {
      id: user.student_id,
      email: user.email,
      name: `${user.first_name} ${user.last_name}`,
      major: user.major,
      gpa: user.gpa
    };

    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({ message: 'Authentication error' });
  }
};

module.exports = requireAuth;