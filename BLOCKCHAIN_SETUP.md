# 🚀 AgriChain Blockchain Integration Setup Guide

This guide will help you set up the complete blockchain integration for your AgriChain Flutter application with traceability, escrow payments, and consumer verification.

## 📋 Prerequisites

Before starting, ensure you have:

- Node.js (v16 or higher)
- npm or yarn
- Flutter SDK
- Git
- A code editor (VS Code recommended)

## 🔧 Step 1: Install Dependencies

### Backend Dependencies
```bash
cd d:\SIH_AgriChain-1
npm install
```

### Flutter Dependencies
Add these to your `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  crypto: ^3.0.3
  qr_code_scanner: ^1.0.1
  qr_flutter: ^4.1.0
  web3dart: ^2.7.3  # For direct blockchain interaction
```

## ⛓️ Step 2: Setup Hardhat Blockchain

### Install Hardhat
```bash
# Install Hardhat globally (optional)
npm install -g hardhat

# Verify installation
npx hardhat --version
```

### Start Local Blockchain
```bash
# Start Hardhat node (keep this running in a separate terminal)
npx hardhat node
```

This will:
- Start a local Ethereum network on `http://localhost:8545`
- Generate 20 test accounts with 10,000 ETH each
- Display all account addresses and private keys

### Deploy Smart Contracts
```bash
# In a new terminal, deploy contracts
npm run deploy

# Or manually:
npx hardhat run scripts/deploy.js --network localhost
```

## 🏦 Step 3: Account Distribution

After deployment, accounts are automatically distributed:

### Farmers (Accounts 1-5)
```
Account 1: 0x70997970c51812dc3a010c7d01b50e0d17dc79c8
Account 2: 0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc
Account 3: 0x90f79bf6eb2c4f870365e785982e1f101e93b906
Account 4: 0x15d34aaf54267db7d7c367839aaf71a00a2c6a65
Account 5: 0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc
```

### Distributors (Accounts 6-10)
```
Account 6: 0x976ea74026e726554db657fa54763abd0c3a0aa9
Account 7: 0x14dc79964da2c08b23698b3d3cc7ca32193d9955
Account 8: 0x23618e81e3f5cdf7f54c3d65f7fbc0abf5b21e8f
Account 9: 0xa0ee7a142d267c1f36714e4a8f75612f20a79720
Account 10: 0xbcd4042de499d14e55001ccbb24a551f3b954096
```

### Retailers (Accounts 11-15)
```
Account 11: 0x71be63f3384f5fb98995898a86b02fb2426c5788
Account 12: 0xfabb0ac9d68b0b445fb7357272ff202c5651694a
Account 13: 0x1cbd3b2770909d4e10f157cabc84c7264073c9ec
Account 14: 0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097
Account 15: 0xcd3b766ccdd6ae721141f452c550ca635964ce71
```

### Consumers (Accounts 16-20)
```
Account 16: 0x2546bcd3c84621e976d8185a91a922ae77ecec30
Account 17: 0xbda5747bfd65f08deb54cb465eb87d40e51b197e
Account 18: 0xdd2fd4581271e230360230f9337d5c0430bf44c0
Account 19: 0x8626f6940e2eb28930efb4cef49b2d1f2c9c1199
Account 20: (if available)
```

## 📱 Step 4: Flutter Integration

### Update Contract Addresses

After deployment, update the contract addresses in your Flutter services:

**File:** `lib/core/services/smart_contract_service.dart`

```dart
// Update these with your deployed contract addresses
static const String _productRegistryAddress = 'YOUR_PRODUCT_REGISTRY_ADDRESS';
static const String _traceabilityAddress = 'YOUR_TRACEABILITY_ADDRESS';
static const String _escrowPaymentAddress = 'YOUR_ESCROW_PAYMENT_ADDRESS';
```

### Integration with Existing Auth Service

**File:** `lib/core/services/auth_service.dart`

Add wallet assignment in user creation:

```dart
import 'blockchain_aadhaar_service.dart';

// In _createMockUser and _createUserFromData methods, add:
final walletAddress = BlockchainAadhaarService.assignWalletToUser(id, role);

// Store wallet address in user model or preferences
await _prefs!.setString('user_wallet_address', walletAddress);
```

## 🔄 Step 5: Workflow Implementation

### Product Registration (Farmer)
```dart
// 1. Farmer registers product
final result = await SmartContractService.registerProduct(
  productId: 'PROD_001',
  productName: 'Organic Tomatoes',
  basePrice: 0.01, // ETH
  farmerId: currentUser.id,
  farmerWalletAddress: currentUser.walletAddress,
);

// 2. QR code generated automatically
// result.qrCodeHash contains the blockchain QR hash
```

### QR Code Scanning & Ownership Transfer
```dart
// When QR is scanned by distributor/retailer
final transferResult = await SmartContractService.transferOwnership(
  productId: scannedProductId,
  qrCodeHash: scannedQRHash,
  fromWallet: currentOwnerWallet,
  toWallet: scannerWallet,
  fromRole: 'farmer', // or current role
  toRole: 'distributor', // scanner's role
  additionalCost: 0.005, // Transport/margin cost in ETH
  location: 'Current GPS location',
  metadata: {
    'transport_method': 'truck',
    'temperature': '5°C',
    'humidity': '60%',
  },
);
```

### Consumer Order & Payment
```dart
// Consumer places order
final orderResult = await SmartContractService.createEscrowOrder(
  orderId: 'ORD_${DateTime.now().millisecondsSinceEpoch}',
  productId: productId,
  consumerWallet: consumerWallet,
  farmerWallet: product.farmerWallet,
  distributorWallet: product.distributorWallet,
  retailerWallet: product.retailerWallet,
  totalAmount: totalPrice, // Calculated from cost breakdown
);
```

### Consumer Verification & Payment Release
```dart
// When consumer scans QR at delivery
final verificationResult = await BlockchainAadhaarService.verifyConsumerOrder(
  consumerId: currentUser.id,
  productQrId: scannedQRHash,
  aadhaarNumber: userAadhaar,
);

if (verificationResult.verified) {
  // Automatically trigger payment release
  final paymentResult = await SmartContractService.releaseEscrowPayment(
    orderId: verificationResult.orderId!,
    qrCodeHash: scannedQRHash,
    consumerWallet: consumerWallet,
  );
  
  // Payment distributed:
  // - Farmer gets base price
  // - Distributor gets transport cost
  // - Retailer gets margin
}
```

## 📊 Step 6: Traceability Implementation

### View Product Journey
```dart
final traceability = await SmartContractService.getProductTraceability(
  productId: productId,
);

// Display journey:
print('Farmer: ${traceability.farmer.wallet} at ${traceability.farmer.timestamp}');
print('Distributor: ${traceability.distributor?.wallet} at ${traceability.distributor?.timestamp}');
print('Retailer: ${traceability.retailer?.wallet} at ${traceability.retailer?.timestamp}');
print('Consumer: ${traceability.consumer?.wallet} at ${traceability.consumer?.timestamp}');
print('Total Cost: ${traceability.totalCost} ETH');
```

## 🛠️ Step 7: Backend API Setup

Create a Node.js backend to handle blockchain interactions:

### Express Server Setup
```javascript
const express = require('express');
const { ethers } = require('ethers');

const app = express();
app.use(express.json());

// Connect to Hardhat node
const provider = new ethers.JsonRpcProvider('http://localhost:8545');

// Contract instances
const productRegistry = new ethers.Contract(PRODUCT_REGISTRY_ADDRESS, ABI, provider);
const traceability = new ethers.Contract(TRACEABILITY_ADDRESS, ABI, provider);
const escrowPayment = new ethers.Contract(ESCROW_PAYMENT_ADDRESS, ABI, provider);

// API endpoints
app.post('/api/blockchain/register-product', async (req, res) => {
  // Handle product registration
});

app.post('/api/blockchain/transfer-ownership', async (req, res) => {
  // Handle ownership transfer
});

app.post('/api/blockchain/release-escrow-payment', async (req, res) => {
  // Handle payment release
});

app.listen(3000, () => {
  console.log('Blockchain API server running on port 3000');
});
```

## 🧪 Step 8: Testing

### Test the Complete Flow

1. **Start Services:**
   ```bash
   # Terminal 1: Start Hardhat node
   npx hardhat node
   
   # Terminal 2: Deploy contracts
   npm run deploy
   
   # Terminal 3: Start backend server
   npm start
   
   # Terminal 4: Run Flutter app
   flutter run
   ```

2. **Test Scenario:**
   - Farmer registers product → Gets QR code
   - Distributor scans QR → Ownership transfers + transport cost added
   - Retailer scans QR → Ownership transfers + margin added
   - Consumer places order → Payment held in escrow
   - Consumer scans QR at delivery → Payment automatically released

### Verify Transactions
```bash
# Check account balances
npx hardhat console --network localhost

# In console:
const accounts = await ethers.getSigners();
const balance = await ethers.provider.getBalance(accounts[0].address);
console.log(ethers.formatEther(balance));
```

## 🔧 Troubleshooting

### Common Issues

1. **"User not registered" error:**
   - Ensure wallet addresses are properly registered in deployment script
   - Check that user roles match blockchain roles (0=Farmer, 1=Distributor, 2=Retailer, 3=Consumer)

2. **"Invalid role transition" error:**
   - Verify ownership transfer sequence: Farmer → Distributor → Retailer → Consumer
   - Cannot skip roles or go backwards

3. **"Insufficient payment" error:**
   - Ensure escrow payment covers base price + all additional costs
   - Check cost breakdown calculation

4. **Network connection issues:**
   - Verify Hardhat node is running on localhost:8545
   - Check Flutter app network configuration for platform

### Reset Blockchain State
```bash
# Stop Hardhat node and restart
npx hardhat node --reset

# Redeploy contracts
npm run deploy
```

## 📚 Additional Resources

- [Hardhat Documentation](https://hardhat.org/docs)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Ethers.js Documentation](https://docs.ethers.org/)
- [Flutter Web3 Integration](https://pub.dev/packages/web3dart)

## 🎯 Next Steps

1. **Production Deployment:**
   - Deploy to Ethereum testnet (Sepolia/Goerli)
   - Update network configuration
   - Add proper error handling

2. **Enhanced Features:**
   - Add dispute resolution mechanism
   - Implement product recall functionality
   - Add temperature/quality sensors integration

3. **Security:**
   - Add access control for admin functions
   - Implement rate limiting
   - Add transaction monitoring

4. **UI/UX:**
   - Create traceability timeline view
   - Add real-time transaction status
   - Implement push notifications for status updates

---

**🎉 Congratulations!** You now have a fully integrated blockchain-based supply chain system with:
- ✅ Product traceability via QR codes
- ✅ Automated fair payment distribution
- ✅ Consumer verification for payment release
- ✅ Immutable record keeping
- ✅ Role-based access control