const db = require('../config/config');
const bcrypt = require('bcryptjs');

const findUserByEmail = async (email) => {
  try {
    const result = await db.query('SELECT * FROM student WHERE email = $1', [email]);
    return result.rows[0];
  } catch (error) {
    throw error;
  }
};

const verifyPassword = async (plainPassword, hashedPassword) => {
  return await bcrypt.compare(plainPassword, hashedPassword);
};

module.exports = {
  findUserByEmail,
  verifyPassword
};