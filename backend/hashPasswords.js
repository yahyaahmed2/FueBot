const db = require('./config/config');
const bcrypt = require('bcryptjs');

async function hashExistingPasswords() {
  try {
    console.log('Starting password hashing...');

    // Get all users with plain text passwords
    const result = await db.query('SELECT student_id, password FROM student');

    for (const user of result.rows) {
      // Check if password is already hashed (bcrypt hashes start with $2a$ or $2b$)
      if (!user.password.startsWith('$2')) {
        console.log(`Hashing password for user ${user.student_id}`);

        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(user.password, saltRounds);

        await db.query('UPDATE student SET password = $1 WHERE student_id = $2', [
          hashedPassword,
          user.student_id
        ]);

        console.log(`Updated password for user ${user.student_id}`);
      } else {
        console.log(`Password for user ${user.student_id} is already hashed`);
      }
    }

    console.log('Password hashing completed!');
  } catch (error) {
    console.error('Error hashing passwords:', error);
  } finally {
    process.exit();
  }
}

hashExistingPasswords();