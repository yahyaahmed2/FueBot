const db = require('../config/config');
const bcrypt = require('bcryptjs');

// LOGIN
const findUserByEmailWithPassword = async (email) => {
  const result = await db.query(
    'SELECT student_id, email, password FROM student WHERE email = $1',
    [email]
  );
  return result.rows[0];
};

// USER DATA (middleware)
const findUserByEmail = async (email) => {
  const result = await db.query(
    'SELECT student_id, first_name, last_name, email, major, gpa FROM student WHERE email = $1',
    [email]
  );
  return result.rows[0];
};
const verifyPassword = async (plainPassword, hashedPassword) => {
  return await bcrypt.compare(plainPassword, hashedPassword);
};

module.exports = {
  findUserByEmailWithPassword,
  findUserByEmail,
  verifyPassword
};