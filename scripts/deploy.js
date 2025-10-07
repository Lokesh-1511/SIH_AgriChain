const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting AgriChain Smart Contract Deployment...\n");

  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log("🔑 Deploying contracts with account:", deployer.address);
  console.log("💰 Account balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // Deploy ProductRegistry
  console.log("📦 Deploying ProductRegistry...");
  const ProductRegistry = await ethers.getContractFactory("ProductRegistry");
  const productRegistry = await ProductRegistry.deploy();
  await productRegistry.waitForDeployment();
  const productRegistryAddress = await productRegistry.getAddress();
  console.log("✅ ProductRegistry deployed to:", productRegistryAddress);

  // Deploy Traceability
  console.log("\n🔍 Deploying Traceability...");
  const Traceability = await ethers.getContractFactory("Traceability");
  const traceability = await Traceability.deploy(productRegistryAddress);
  await traceability.waitForDeployment();
  const traceabilityAddress = await traceability.getAddress();
  console.log("✅ Traceability deployed to:", traceabilityAddress);

  // Deploy EscrowPayment
  console.log("\n💳 Deploying EscrowPayment...");
  const EscrowPayment = await ethers.getContractFactory("EscrowPayment");
  const escrowPayment = await EscrowPayment.deploy(productRegistryAddress, traceabilityAddress);
  await escrowPayment.waitForDeployment();
  const escrowPaymentAddress = await escrowPayment.getAddress();
  console.log("✅ EscrowPayment deployed to:", escrowPaymentAddress);

  // Setup accounts and roles
  console.log("\n👥 Setting up user accounts and roles...");
  const accounts = await ethers.getSigners();
  
  // Define role assignments (5 accounts per role)
  const farmers = accounts.slice(1, 6);      // accounts[1-5]
  const distributors = accounts.slice(6, 11); // accounts[6-10]
  const retailers = accounts.slice(11, 16);   // accounts[11-15]
  const consumers = accounts.slice(16, 21);   // accounts[16-20] (if available)

  // Register farmers
  console.log("🌾 Registering farmers...");
  for (let i = 0; i < farmers.length; i++) {
    if (farmers[i]) {
      await productRegistry.registerUser(farmers[i].address, 0); // UserRole.Farmer = 0
      console.log(`   Farmer ${i + 1}: ${farmers[i].address}`);
    }
  }

  // Register distributors
  console.log("🚛 Registering distributors...");
  for (let i = 0; i < distributors.length; i++) {
    if (distributors[i]) {
      await productRegistry.registerUser(distributors[i].address, 1); // UserRole.Distributor = 1
      console.log(`   Distributor ${i + 1}: ${distributors[i].address}`);
    }
  }

  // Register retailers
  console.log("🏪 Registering retailers...");
  for (let i = 0; i < retailers.length; i++) {
    if (retailers[i]) {
      await productRegistry.registerUser(retailers[i].address, 2); // UserRole.Retailer = 2
      console.log(`   Retailer ${i + 1}: ${retailers[i].address}`);
    }
  }

  // Register consumers (if enough accounts available)
  console.log("🛒 Registering consumers...");
  for (let i = 0; i < consumers.length && consumers[i]; i++) {
    await productRegistry.registerUser(consumers[i].address, 3); // UserRole.Consumer = 3
    console.log(`   Consumer ${i + 1}: ${consumers[i].address}`);
  }

  // Create a demo product
  console.log("\n🌽 Creating demo product...");
  const farmerSigner = farmers[0];
  const demoProductId = "PROD_DEMO_001";
  const demoQRHash = "QR_DEMO_HASH_001";
  
  await productRegistry.connect(farmerSigner).registerProduct(
    demoProductId,
    "Organic Tomatoes - 1kg",
    ethers.parseEther("0.01"), // 0.01 ETH base price
    demoQRHash
  );
  console.log(`   Demo product created: ${demoProductId}`);
  console.log(`   QR Hash: ${demoQRHash}`);
  console.log(`   Base price: 0.01 ETH`);

  // Create traceability record for demo product
  await traceability.createTraceabilityRecord(demoProductId, demoQRHash);
  console.log("   Traceability record created");

  // Summary
  console.log("\n" + "=".repeat(60));
  console.log("🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!");
  console.log("=".repeat(60));
  console.log(`📦 ProductRegistry:  ${productRegistryAddress}`);
  console.log(`🔍 Traceability:     ${traceabilityAddress}`);
  console.log(`💳 EscrowPayment:    ${escrowPaymentAddress}`);
  console.log("=".repeat(60));
  
  // Save deployment info
  const deploymentInfo = {
    network: "localhost",
    deployer: deployer.address,
    deployedAt: new Date().toISOString(),
    contracts: {
      ProductRegistry: productRegistryAddress,
      Traceability: traceabilityAddress,
      EscrowPayment: escrowPaymentAddress
    },
    accounts: {
      deployer: deployer.address,
      farmers: farmers.map(f => f?.address).filter(Boolean),
      distributors: distributors.map(d => d?.address).filter(Boolean),
      retailers: retailers.map(r => r?.address).filter(Boolean),
      consumers: consumers.map(c => c?.address).filter(Boolean)
    },
    demoProduct: {
      productId: demoProductId,
      qrHash: demoQRHash,
      farmer: farmerSigner.address
    }
  };

  // Write deployment info to file
  const fs = require('fs');
  const path = require('path');
  
  const outputDir = path.join(__dirname, '../deployment');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  fs.writeFileSync(
    path.join(outputDir, 'deployment-info.json'),
    JSON.stringify(deploymentInfo, null, 2)
  );
  
  console.log(`\n📄 Deployment info saved to: deployment/deployment-info.json`);
  console.log("\n🚀 Ready for Flutter integration!");
  console.log("\n💡 Next steps:");
  console.log("   1. Update Flutter app with contract addresses");
  console.log("   2. Test QR code scanning and traceability");
  console.log("   3. Test escrow payment system");
  console.log("   4. Verify consumer order verification flow");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });