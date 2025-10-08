const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs').promises;

const app = express();
const PORT = 8080;

// Enable CORS for all routes
app.use(cors());
app.use(express.json());

// Serve static files (HTML explorer)
app.use(express.static('.'));

// API endpoint to get registration data for HTML explorer
app.get('/api/registrations', async (req, res) => {
    try {
        // Try to read from web_registrations.json first
        let registrations = null;
        
        try {
            const webData = await fs.readFile('web_registrations.json', 'utf8');
            if (webData.trim()) {
                registrations = JSON.parse(webData);
            }
        } catch (e) {
            console.log('Could not read web_registrations.json, using empty data');
        }
        
        // If no web data, create empty structure
        if (!registrations) {
            registrations = {
                lastUpdated: new Date().toISOString(),
                totalUsers: 0,
                users: {},
                walletAssignments: {},
                statistics: {
                    farmers: 0,
                    distributors: 0,
                    retailers: 0,
                    consumers: 0
                }
            };
        }
        
        res.json(registrations);
    } catch (error) {
        console.error('Error reading registrations:', error);
        res.status(500).json({ error: 'Failed to read registrations' });
    }
});

// API endpoint to update registration data (from Flutter app)
app.post('/api/registrations', async (req, res) => {
    try {
        const newRegistration = req.body;
        
        // Read existing data
        let registrations = {
            lastUpdated: new Date().toISOString(),
            totalUsers: 0,
            users: {},
            walletAssignments: {},
            statistics: {
                farmers: 0,
                distributors: 0,
                retailers: 0,
                consumers: 0
            }
        };
        
        try {
            const existingData = await fs.readFile('web_registrations.json', 'utf8');
            if (existingData.trim()) {
                registrations = JSON.parse(existingData);
            }
        } catch (e) {
            console.log('Creating new registrations file');
        }
        
        // Add new registration
        const userId = newRegistration.userId;
        registrations.users[userId] = newRegistration;
        
        // Update statistics
        const stats = { farmers: 0, distributors: 0, retailers: 0, consumers: 0 };
        Object.values(registrations.users).forEach(user => {
            const role = user.role;
            if (stats.hasOwnProperty(role + 's')) {
                stats[role + 's']++;
            }
        });
        
        registrations.statistics = stats;
        registrations.totalUsers = Object.keys(registrations.users).length;
        registrations.lastUpdated = new Date().toISOString();
        
        // Save to file
        await fs.writeFile('web_registrations.json', JSON.stringify(registrations, null, 2));
        
        res.json({ success: true, message: 'Registration saved' });
    } catch (error) {
        console.error('Error saving registration:', error);
        res.status(500).json({ error: 'Failed to save registration' });
    }
});

app.listen(PORT, () => {
    console.log(`🌐 HTML Explorer Server running on http://localhost:${PORT}`);
    console.log(`📊 Registration API available at http://localhost:${PORT}/api/registrations`);
    console.log(`📁 Enhanced Blockchain Explorer: http://localhost:${PORT}/enhanced_blockchain_explorer.html`);
});

module.exports = app;