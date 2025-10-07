const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AgriChain Complete Workflow", function () {
  let productRegistry;
  let traceability;
  let escrowPayment;
  let deployer, farmer, distributor, retailer, consumer;
  let productId = "PROD_TEST_001";
  let productName = "Organic Tomatoes - 1kg";
  let basePrice = ethers.parseEther("0.01"); // 0.01 ETH
  let qrCodeHash = "QR_TEST_HASH_001";
  let orderId = "ORD_TEST_001";

  before(async function () {
    // Get signers
    [deployer, farmer, distributor, retailer, consumer] = await ethers.getSigners();

    console.log("\n🚀 Setting up AgriChain Test Environment");
    console.log("👤 Deployer:", deployer.address);
    console.log("🌾 Farmer:", farmer.address);
    console.log("🚛 Distributor:", distributor.address);
    console.log("🏪 Retailer:", retailer.address);
    console.log("🛒 Consumer:", consumer.address);

    // Deploy contracts
    const ProductRegistry = await ethers.getContractFactory("ProductRegistry");
    productRegistry = await ProductRegistry.deploy();
    await productRegistry.waitForDeployment();

    const Traceability = await ethers.getContractFactory("Traceability");
    traceability = await Traceability.deploy(await productRegistry.getAddress());
    await traceability.waitForDeployment();

    const EscrowPayment = await ethers.getContractFactory("EscrowPayment");
    escrowPayment = await EscrowPayment.deploy(
      await productRegistry.getAddress(),
      await traceability.getAddress()
    );
    await escrowPayment.waitForDeployment();

    console.log("\n📦 Contracts deployed:");
    console.log("ProductRegistry:", await productRegistry.getAddress());
    console.log("Traceability:", await traceability.getAddress());
    console.log("EscrowPayment:", await escrowPayment.getAddress());

    // Register users
    await productRegistry.registerUser(farmer.address, 0); // Farmer
    await productRegistry.registerUser(distributor.address, 1); // Distributor
    await productRegistry.registerUser(retailer.address, 2); // Retailer
    await productRegistry.registerUser(consumer.address, 3); // Consumer

    console.log("\n✅ All users registered with their roles");
  });

  describe("📦 Product Registration (Farmer)", function () {
    it("Should register a new product", async function () {
      const tx = await productRegistry.connect(farmer).registerProduct(
        productId,
        productName,
        basePrice,
        qrCodeHash
      );

      await expect(tx)
        .to.emit(productRegistry, "ProductRegistered")
        .withArgs(productId, productName, basePrice, farmer.address, qrCodeHash);

      const product = await productRegistry.getProduct(productId);
      expect(product.productId).to.equal(productId);
      expect(product.farmer).to.equal(farmer.address);
      expect(product.currentOwner).to.equal(farmer.address);
      expect(product.basePrice).to.equal(basePrice);

      console.log("✅ Product registered successfully");
      console.log(`   Product ID: ${productId}`);
      console.log(`   Base Price: ${ethers.formatEther(basePrice)} ETH`);
    });

    it("Should create traceability record", async function () {
      await traceability.createTraceabilityRecord(productId, qrCodeHash);
      
      const [retrievedProductId, scanHistory, isActive] = await traceability.getTrace(qrCodeHash);
      expect(retrievedProductId).to.equal(productId);
      expect(isActive).to.be.true;

      console.log("✅ Traceability record created");
    });
  });

  describe("🚛 Distributor Workflow", function () {
    it("Should record QR scan by distributor", async function () {
      const location = "Distribution Center, City";
      const metaHash = "META_DIST_001";

      const tx = await traceability.connect(distributor).recordScan(
        qrCodeHash,
        location,
        metaHash
      );

      await expect(tx)
        .to.emit(traceability, "QRCodeScanned")
        .withArgs(productId, qrCodeHash, distributor.address, 1, await getLatestTimestamp(), location);

      console.log("✅ Distributor QR scan recorded");
    });

    it("Should transfer ownership to distributor", async function () {
      const transportCost = ethers.parseEther("0.005"); // 0.005 ETH
      const location = "Distribution Center";
      const metaHash = "META_TRANSPORT_001";

      const tx = await productRegistry.connect(farmer).transferOwnership(
        productId,
        distributor.address,
        1, // Distributor role
        transportCost,
        metaHash,
        location
      );

      await expect(tx)
        .to.emit(productRegistry, "OwnershipTransferred");

      const product = await productRegistry.getProduct(productId);
      expect(product.currentOwner).to.equal(distributor.address);
      expect(product.currentRole).to.equal(1);

      console.log("✅ Ownership transferred to distributor");
      console.log(`   Transport cost: ${ethers.formatEther(transportCost)} ETH`);
    });
  });

  describe("🏪 Retailer Workflow", function () {
    it("Should transfer ownership to retailer", async function () {
      const retailMargin = ethers.parseEther("0.003"); // 0.003 ETH
      const location = "Retail Store";
      const metaHash = "META_RETAIL_001";

      const tx = await productRegistry.connect(distributor).transferOwnership(
        productId,
        retailer.address,
        2, // Retailer role
        retailMargin,
        metaHash,
        location
      );

      await expect(tx)
        .to.emit(productRegistry, "OwnershipTransferred");

      const product = await productRegistry.getProduct(productId);
      expect(product.currentOwner).to.equal(retailer.address);

      console.log("✅ Ownership transferred to retailer");
      console.log(`   Retail margin: ${ethers.formatEther(retailMargin)} ETH`);
    });

    it("Should calculate correct total cost", async function () {
      const [farmerCost, distributorCost, retailerCost, totalCost] = 
        await productRegistry.getCostBreakdown(productId);

      console.log("💰 Cost Breakdown:");
      console.log(`   Farmer: ${ethers.formatEther(farmerCost)} ETH`);
      console.log(`   Distributor: ${ethers.formatEther(distributorCost)} ETH`);
      console.log(`   Retailer: ${ethers.formatEther(retailerCost)} ETH`);
      console.log(`   Total: ${ethers.formatEther(totalCost)} ETH`);

      expect(totalCost).to.equal(farmerCost + distributorCost + retailerCost);
    });
  });

  describe("🛒 Consumer Order & Escrow", function () {
    it("Should create escrow order", async function () {
      const [, , , totalCost] = await productRegistry.getCostBreakdown(productId);
      
      const tx = await escrowPayment.connect(consumer).createOrder(
        orderId,
        productId,
        farmer.address,
        distributor.address,
        retailer.address,
        { value: totalCost }
      );

      await expect(tx)
        .to.emit(escrowPayment, "OrderCreated")
        .withArgs(orderId, productId, consumer.address, totalCost, [
          ethers.parseEther("0.01"),   // Farmer
          ethers.parseEther("0.005"),  // Distributor  
          ethers.parseEther("0.003")   // Retailer
        ]);

      const order = await escrowPayment.getOrder(orderId);
      expect(order.consumer).to.equal(consumer.address);
      expect(order.status).to.equal(1); // Paid status

      console.log("✅ Escrow order created");
      console.log(`   Order ID: ${orderId}`);
      console.log(`   Total Amount: ${ethers.formatEther(totalCost)} ETH`);
    });

    it("Should verify consumer order", async function () {
      const [isValid, returnedOrderId, totalAmount, status] = 
        await escrowPayment.verifyConsumerOrder(
          consumer.address,
          productId,
          qrCodeHash
        );

      expect(isValid).to.be.true;
      expect(returnedOrderId).to.equal(orderId);
      expect(status).to.equal(1); // Paid status

      console.log("✅ Consumer order verified");
    });
  });

  describe("📱 Consumer Delivery & Payment Release", function () {
    it("Should record consumer QR scan", async function () {
      const location = "Consumer Home";
      const metaHash = "META_CONSUMER_001";

      const tx = await traceability.connect(consumer).recordScan(
        qrCodeHash,
        location,
        metaHash
      );

      await expect(tx)
        .to.emit(traceability, "QRCodeScanned");

      console.log("✅ Consumer QR scan recorded");
    });

    it("Should transfer final ownership to consumer", async function () {
      const tx = await productRegistry.connect(retailer).transferOwnership(
        productId,
        consumer.address,
        3, // Consumer role
        0, // No additional cost
        "META_FINAL_001",
        "Consumer Home"
      );

      await expect(tx)
        .to.emit(productRegistry, "OwnershipTransferred");

      const product = await productRegistry.getProduct(productId);
      expect(product.currentOwner).to.equal(consumer.address);
      expect(product.currentRole).to.equal(3);

      console.log("✅ Final ownership transferred to consumer");
    });

    it("Should release escrow payment", async function () {
      // Record initial balances
      const farmerBalanceBefore = await ethers.provider.getBalance(farmer.address);
      const distributorBalanceBefore = await ethers.provider.getBalance(distributor.address);
      const retailerBalanceBefore = await ethers.provider.getBalance(retailer.address);

      const tx = await escrowPayment.connect(consumer).confirmDeliveryAndRelease(
        orderId,
        qrCodeHash
      );

      await expect(tx)
        .to.emit(escrowPayment, "PaymentReleased");

      // Check final balances
      const farmerBalanceAfter = await ethers.provider.getBalance(farmer.address);
      const distributorBalanceAfter = await ethers.provider.getBalance(distributor.address);
      const retailerBalanceAfter = await ethers.provider.getBalance(retailer.address);

      const farmerGain = farmerBalanceAfter - farmerBalanceBefore;
      const distributorGain = distributorBalanceAfter - distributorBalanceBefore;
      const retailerGain = retailerBalanceAfter - retailerBalanceBefore;

      console.log("💸 Payment Released:");
      console.log(`   Farmer received: ${ethers.formatEther(farmerGain)} ETH`);
      console.log(`   Distributor received: ${ethers.formatEther(distributorGain)} ETH`);
      console.log(`   Retailer received: ${ethers.formatEther(retailerGain)} ETH`);

      // Verify payment amounts
      expect(farmerGain).to.equal(ethers.parseEther("0.01"));
      expect(distributorGain).to.equal(ethers.parseEther("0.005"));
      expect(retailerGain).to.equal(ethers.parseEther("0.003"));
    });

    it("Should show complete traceability", async function () {
      const [, scanHistory] = await traceability.getTrace(qrCodeHash);
      
      console.log("\n🔍 Complete Product Traceability:");
      console.log(`📦 Product: ${productName} (${productId})`);
      console.log("🛤️  Journey:");
      
      for (let i = 0; i < scanHistory.length; i++) {
        const scan = scanHistory[i];
        const roles = ["🌾 Farmer", "🚛 Distributor", "🏪 Retailer", "🛒 Consumer"];
        console.log(`   ${i + 1}. ${roles[scan.scannerRole]} - ${scan.location}`);
        console.log(`      Wallet: ${scan.scanner}`);
        console.log(`      Time: ${new Date(Number(scan.timestamp) * 1000).toLocaleString()}`);
      }

      expect(scanHistory.length).to.equal(4); // All four roles scanned
    });
  });

  describe("📊 Final Verification", function () {
    it("Should verify complete workflow", async function () {
      const product = await productRegistry.getProduct(productId);
      const order = await escrowPayment.getOrder(orderId);
      const [, , , totalCost] = await productRegistry.getCostBreakdown(productId);

      // Verify product ownership
      expect(product.currentOwner).to.equal(consumer.address);
      expect(product.currentRole).to.equal(3); // Consumer

      // Verify order completion
      expect(order.status).to.equal(4); // Released status
      expect(order.escrowReleased).to.be.true;

      // Verify cost calculation
      expect(totalCost).to.equal(ethers.parseEther("0.018")); // 0.01 + 0.005 + 0.003

      console.log("\n🎉 WORKFLOW COMPLETED SUCCESSFULLY!");
      console.log("✅ Product journey: Farmer → Distributor → Retailer → Consumer");
      console.log("✅ All QR scans recorded on blockchain");
      console.log("✅ Dynamic pricing based on actual costs");
      console.log("✅ Automated payment distribution");
      console.log("✅ Consumer verification successful");
      console.log("✅ Complete traceability maintained");
    });
  });

  // Helper function
  async function getLatestTimestamp() {
    const latestBlock = await ethers.provider.getBlock('latest');
    return latestBlock.timestamp;
  }
});