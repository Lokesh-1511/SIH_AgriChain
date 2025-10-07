const { ethers } = require("hardhat");

async function main() {
    console.log("🔍 BLOCKCHAIN ACTIVITY MONITOR\n");
    
    // Get provider
    const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
    
    // Get latest block number
    const latestBlock = await provider.getBlockNumber();
    console.log(`📦 Latest Block Number: ${latestBlock}\n`);
    
    // Contract addresses (update these after deployment)
    const productRegistryAddress = "0x5FbDB2315678afEcb367f032d93F642f64180aa3";
    const traceabilityAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
    const escrowAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
    
    console.log("📋 CONTRACT ADDRESSES:");
    console.log(`   ProductRegistry: ${productRegistryAddress}`);
    console.log(`   Traceability: ${traceabilityAddress}`);
    console.log(`   EscrowPayment: ${escrowAddress}\n`);
    
    // Get contract instances
    const ProductRegistry = await ethers.getContractFactory("ProductRegistry");
    const productRegistry = ProductRegistry.attach(productRegistryAddress);
    
    const Traceability = await ethers.getContractFactory("Traceability");
    const traceability = Traceability.attach(traceabilityAddress);
    
    // Check recent blocks for activity
    console.log("🔍 RECENT BLOCKCHAIN ACTIVITY:");
    const startBlock = Math.max(1, latestBlock - 10); // Last 10 blocks
    
    for (let i = startBlock; i <= latestBlock; i++) {
        const block = await provider.getBlock(i);
        if (block.transactions.length > 0) {
            console.log(`\n   Block #${i}: ${block.transactions.length} transaction(s)`);
            console.log(`   Timestamp: ${new Date(block.timestamp * 1000).toLocaleString()}`);
            
            // Check each transaction
            for (const txHash of block.transactions) {
                const tx = await provider.getTransaction(txHash);
                const receipt = await provider.getTransactionReceipt(txHash);
                
                let activity = "Unknown";
                if (tx.to === productRegistryAddress) {
                    activity = "ProductRegistry interaction";
                } else if (tx.to === traceabilityAddress) {
                    activity = "Traceability interaction";
                } else if (tx.to === escrowAddress) {
                    activity = "EscrowPayment interaction";
                } else if (tx.to === null) {
                    activity = "Contract Deployment";
                }
                
                console.log(`     - ${activity} | Gas: ${receipt.gasUsed} | Status: ${receipt.status ? '✅' : '❌'}`);
            }
        }
    }
    
    // Check registered users count
    try {
        const totalUsers = await productRegistry.totalUsers();
        console.log(`\n👥 REGISTERED USERS: ${totalUsers}`);
        
        // Check users by role
        console.log("\n📊 USERS BY ROLE:");
        let farmerCount = 0, distributorCount = 0, retailerCount = 0, consumerCount = 0;
        
        for (let i = 0; i < totalUsers; i++) {
            const userAddr = await productRegistry.userAddresses(i);
            const role = await productRegistry.getUserRole(userAddr);
            
            switch(role) {
                case 1: farmerCount++; break;
                case 2: distributorCount++; break;
                case 3: retailerCount++; break;
                case 4: consumerCount++; break;
            }
        }
        
        console.log(`   👨‍🌾 Farmers: ${farmerCount}`);
        console.log(`   🚛 Distributors: ${distributorCount}`);
        console.log(`   🏪 Retailers: ${retailerCount}`);
        console.log(`   👤 Consumers: ${consumerCount}`);
        
    } catch (error) {
        console.log("⚠️  Could not fetch user data:", error.message);
    }
    
    // Check products count
    try {
        const totalProducts = await productRegistry.totalProducts();
        console.log(`\n📦 REGISTERED PRODUCTS: ${totalProducts}`);
        
        if (totalProducts > 0) {
            console.log("\n🌾 RECENT PRODUCTS:");
            const recentCount = Math.min(5, Number(totalProducts));
            
            for (let i = 0; i < recentCount; i++) {
                const productId = await productRegistry.productIds(i);
                const product = await productRegistry.getProduct(productId);
                console.log(`   - Product ID: ${productId}`);
                console.log(`     Name: ${product.name}`);
                console.log(`     Owner: ${product.currentOwner}`);
                console.log(`     Created: ${new Date(Number(product.createdAt) * 1000).toLocaleString()}`);
            }
        }
        
    } catch (error) {
        console.log("⚠️  Could not fetch product data:", error.message);
    }
    
    console.log("\n" + "=".repeat(60));
    console.log("✅ Blockchain monitoring complete!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Error:", error);
        process.exit(1);
    });