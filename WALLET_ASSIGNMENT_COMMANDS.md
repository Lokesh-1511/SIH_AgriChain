# Complete Command Sequence for Wallet Assignment & HTML Integration

## Prerequisites Setup Commands

### 1. Start Hardhat Blockchain Node
```powershell
# Terminal 1: Start Hardhat node (keep running)
cd D:\SIH_AgriChain-1
npx hardhat node --hostname 0.0.0.0 --port 8545
```

### 2. Deploy Smart Contracts
```powershell
# Terminal 2: Deploy contracts
cd D:\SIH_AgriChain-1
npx hardhat run scripts/deploy.js --network localhost
```

### 3. Start MongoDB (if using real MongoDB)
```powershell
# Terminal 3: Start MongoDB service
net start MongoDB
# OR if using Docker:
# docker run -d -p 27017:27017 --name mongodb mongo:latest
```

### 4. Start Wallet API Server
```powershell
# Terminal 4: Start wallet assignment API
cd D:\SIH_AgriChain-1
node wallet-api-server.js
```

## Wallet Assignment & HTML Integration Flow

### Step 1: User Registration in Flutter App
When user registers in Flutter:
1. AuthService.registerUser() is called
2. Firebase authentication creates user
3. WalletAssignmentService.getOrAssignWallet() assigns blockchain address
4. User object updated with walletAddress
5. MongoDBService.createUser() saves to MongoDB with wallet
6. BlockchainExplorerService.notifyUserRegistration() syncs to HTML

### Step 2: HTML Explorer Auto-Refresh
The HTML explorer automatically:
1. Fetches wallet assignments from API every 5 seconds
2. Displays registered users with their roles and wallet addresses
3. Updates unassigned wallet list (excludes assigned ones)
4. Shows MongoDB connection status

## Commands to Verify Integration

### Check Wallet Assignment Status
```powershell
# Check current wallet assignments
curl http://localhost:3001/api/wallet-assignments
```

### Check specific wallet
```powershell
# Check if specific address is assigned
curl http://localhost:3001/api/wallet-check/0x70997970C51812dc3A010C7d01b50e0d17dc79C8
```

### Check MongoDB Connection
```powershell
# Check API health and MongoDB status
curl http://localhost:3001/api/health
```

### Open HTML Explorer
```powershell
# Open explorer in browser (auto-refreshes every 5 seconds)
start http://localhost:8080/enhanced_blockchain_explorer.html
```

## Troubleshooting Commands

### Restart Services
```powershell
# Kill existing node processes
Get-Process | Where-Object {$_.ProcessName -eq "node"} | Stop-Process -Force

# Restart wallet API server
cd D:\SIH_AgriChain-1
node wallet-api-server.js
```

### Clean Flutter Build (for Android SSL issues)
```powershell
cd D:\SIH_AgriChain-1
flutter clean
flutter pub get
flutter run
```

### Check Hardhat Accounts
```powershell
cd D:\SIH_AgriChain-1
npx hardhat run scripts/list-accounts.js --network localhost
```

## Real-time Flow Summary:
1. Flutter Registration → Wallet Assignment → MongoDB Storage → HTML Update
2. HTML fetches from API every 5 seconds → Shows registered users with wallets
3. Assigned addresses removed from unassigned list
4. All data persists across Hardhat restarts via MongoDB

## File Locations:
- Wallet assignments: MongoDB + wallet_assignments.json (backup)
- User registrations: MongoDB + web_registrations.json (sync)
- HTML Explorer: enhanced_blockchain_explorer.html
- API Server: wallet-api-server.js