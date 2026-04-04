require('dotenv').config();
const express = require('express');
const sessionMiddleware = require('./config/config');
const authRoutes = require('./routes/authRoutes');

const app = express();

app.use(express.json());
app.use(sessionMiddleware);
app.use('/auth', authRoutes);

app.listen(process.env.PORT || 5000, () =>
  console.log('Server running')
);