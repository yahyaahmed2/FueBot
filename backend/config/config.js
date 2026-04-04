const session = require('express-session');
const { Pool } = require('pg'); 
require('dotenv').config();    

const pool = new Pool({
  user: process.env.PGUSER,
  host: process.env.PGHOST || 'localhost',
  database: process.env.PGDATABASE,
  password: process.env.PGPASSWORD,
  port: process.env.PGPORT || 5432,
});

pool.on('error', (err, client) => {
  console.error('Idle client error', err.message, err.stack);
});

if(!process.env.SESSION_SECRET){
  throw new Error("Session secret not found in Environment variables")
};
const sessionConfig = session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 1000 * 60 * 60 }
});

module.exports = {
  query: (text, params, callback) => {
    return pool.query(text, params, callback);
  },
  connect: () => pool.connect(),
  sessionConfig
};