const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const mysql = require('mysql');
require('dotenv').config(); // Load .env file

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// MySQL Connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'flutter_app',
});

db.connect((err) => {
    if (err) {
        console.error('❌ Error connecting to MySQL:', err);
        return;
    }
    console.log('✅ Connected to MySQL database.');
});

// Secret key for JWT
const SECRET_KEY = process.env.JWT_SECRET || 'fallback_secret_key'; // Load from .env

// API Endpoint: Register a User
app.post('/register', async (req, res) => {
    const { name, password, biometricUsed } = req.body;

    try {
        const hashedPassword = await bcrypt.hash(password, 10);

        const query = 'INSERT INTO users (name, password, biometric_used) VALUES (?, ?, ?)';
        db.query(query, [name, hashedPassword, biometricUsed], (err, result) => {
            if (err) {
                console.error('⚠️ Error inserting user:', err);
                return res.status(500).json({ error: 'User already exists or database error' });
            }
            res.status(200).json({ message: 'User registered successfully' });
        });
    } catch (err) {
        console.error('⚠️ Error hashing password:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// API Endpoint: Login a User
app.post('/login', (req, res) => {
    const { name, password } = req.body;

    const query = 'SELECT * FROM users WHERE name = ?';
    db.query(query, [name], async (err, results) => {
        if (err) {
            console.error('⚠️ Error fetching user:', err);
            return res.status(500).json({ error: 'Internal server error' });
        }

        if (results.length === 0) {
            return res.status(401).json({ error: 'Invalid name or password' });
        }

        const user = results[0];

        // Biometric login: skip password if biometricUsed is true
        if (!password && user.biometric_used) {
            const token = jwt.sign({ id: user.id, name: user.name }, SECRET_KEY, { expiresIn: '1h' });
            return res.status(200).json({ message: 'Biometric login successful', token });
        }

        // Normal password login
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({ error: 'Invalid name or password' });
        }

        const token = jwt.sign({ id: user.id, name: user.name }, SECRET_KEY, { expiresIn: '1h' });
        res.status(200).json({ message: 'Login successful', token });
    });
});

// Start the Server
app.listen(port, () => {
    console.log(`🚀 Server running at http://localhost:${port}`);
});
