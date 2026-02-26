const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
require('dotenv').config();


const app = express();
app.use(bodyParser.json());
app.use(session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {maxAge: 1000 * 60 * 60}
}));

app.get('/', (req, res) => {
    res.send("Server is running")
});

const port = process.env.PORT || 5000;

app.listen(port, () => console.log(`Server listening on port ${port}`));
