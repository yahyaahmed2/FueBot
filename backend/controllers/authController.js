const users = require('../models/userModel');

exports.login = (req, res) => {
  const { username, password } = req.body;

  const user = users.find(
    u => u.username === username && u.password === password
  );

  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  req.session.userId = user.id;
  res.json({ message: 'Logged in' });
};

exports.logout = (req, res) => {
  req.session.destroy(() => {
    res.json({ message: 'Logged out' });
  });
};

exports.dashboard = (req, res) => {
  res.json({ message: 'Welcome to dashboard' });
};