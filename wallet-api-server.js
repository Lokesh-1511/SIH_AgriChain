const express = require('express');
const { MongoClient } = require('mongodb');
const cors = require('cors');

const app = express();
const port = 3001;

// MongoDB connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017';
const DB_NAME = 'agrichain';

app.use(cors());
app.use(express.json());

let db;

// Connect to MongoDB
MongoClient.connect(MONGODB_URI)
  .then(client => {
    console.log('✅ Connected to MongoDB');
    db = client.db(DB_NAME);
  })
  .catch(error => {
    console.error('❌ MongoDB connection error:', error);
  });

// Get all wallet assignments from MongoDB
app.get('/api/wallet-assignments', async (req, res) => {
  try {
    let assignments = {};
    let totalAssignments = 0;
    let source = 'unknown';

    // Try MongoDB first - check multiple collections
    if (db) {
      try {
        const collections = ['farmers', 'distributors', 'retailers', 'consumers'];
        let allUsers = [];
        
        for (const collectionName of collections) {
          const users = await db.collection(collectionName).find({
            walletAddress: { $exists: true, $ne: null, $ne: "" }
          }).toArray();
          
          allUsers = allUsers.concat(users);
        }

        const users = allUsers;

        users.forEach(user => {
          const role = user.role;
          if (!assignments[role]) {
            assignments[role] = {};
          }
          
          assignments[role][user.walletAddress] = {
            userId: user._id.toString(),
            name: user.name,
            email: user.email,
            assignedAt: user.createdAt || new Date().toISOString(),
            role: role
          };
        });

        totalAssignments = users.length;
        source = 'mongodb';
        console.log(`📊 Found ${users.length} wallet assignments in MongoDB`);
      } catch (dbError) {
        console.warn('⚠️ MongoDB query failed, trying simulator file:', dbError.message);
      }
    }

    // Fallback to simulator file if MongoDB has no data or failed
    if (totalAssignments === 0) {
      try {
        const fs = require('fs');
        const path = require('path');
        const simulatorFile = path.join(__dirname, 'mongo_wallet_assignments.json');
        
        if (fs.existsSync(simulatorFile)) {
          const simData = JSON.parse(fs.readFileSync(simulatorFile, 'utf8'));
          
          // Convert simulator data to the expected format
          for (const [userId, userData] of Object.entries(simData)) {
            const role = userData.role;
            const wallet = userData.walletAddress;
            
            if (!assignments[role]) {
              assignments[role] = {};
            }
            
            assignments[role][wallet] = {
              userId: userId,
              name: userData.name,
              email: userData.email,
              assignedAt: userData.assignedAt,
              role: role
            };
          }
          
          totalAssignments = Object.keys(simData).length;
          source = 'simulator';
          console.log(`📊 Found ${totalAssignments} wallet assignments in simulator file`);
        }
      } catch (simError) {
        console.warn('⚠️ Simulator file read failed:', simError.message);
      }
    }

    res.json({
      success: true,
      assignments: assignments,
      totalAssignments: totalAssignments,
      source: source,
      lastUpdated: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('❌ Error fetching wallet assignments:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Get assigned wallets for a specific role
app.get('/api/wallet-assignments/:role', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Database not connected' });
    }

    const role = req.params.role;
    
    const users = await db.collection('users').find({
      role: role,
      walletAddress: { $exists: true, $ne: null }
    }).toArray();

    const wallets = users.map(user => ({
      userId: user._id.toString(),
      walletAddress: user.walletAddress,
      name: user.name,
      email: user.email,
      assignedAt: user.createdAt || new Date().toISOString()
    }));

    res.json({
      success: true,
      role: role,
      wallets: wallets,
      count: wallets.length
    });
    
  } catch (error) {
    console.error(`❌ Error fetching ${role} wallet assignments:`, error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Check if a specific wallet is assigned
app.get('/api/wallet-check/:address', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Database not connected' });
    }

    const walletAddress = req.params.address.toLowerCase();
    
    // Check all role-based collections
    const collections = ['farmers', 'distributors', 'retailers', 'consumers'];
    let user = null;
    
    for (const collectionName of collections) {
      user = await db.collection(collectionName).findOne({
        walletAddress: new RegExp(`^${walletAddress}$`, 'i')
      });
      if (user) break;
    }

    if (user) {
      res.json({
        success: true,
        assigned: true,
        user: {
          id: user._id.toString(),
          name: user.name,
          email: user.email,
          role: user.role,
          assignedAt: user.createdAt || new Date().toISOString()
        }
      });
    } else {
      res.json({
        success: true,
        assigned: false,
        user: null
      });
    }
    
  } catch (error) {
    console.error(`❌ Error checking wallet ${req.params.address}:`, error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    mongodb: db ? 'connected' : 'disconnected',
    timestamp: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`🚀 Wallet Assignment API server running on http://localhost:${port}`);
  console.log(`📊 Endpoints:
  - GET /api/wallet-assignments - Get all assignments
  - GET /api/wallet-assignments/:role - Get assignments by role
  - GET /api/wallet-check/:address - Check specific wallet
  - GET /api/health - Health check`);
});

module.exports = app;