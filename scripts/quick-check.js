const { ethers } = require("hardhat");

async function main() {
    console.log("🔍 SIMPLE BLOCKCHAIN CHECK\n");
    
    const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
    
    // Basic blockchain info
    const latestBlock = await provider.getBlockNumber();
    const network = await provider.getNetwork();
    
    console.log(`🌐 Network Chain ID: ${network.chainId}`);
    console.log(`📦 Latest Block: ${latestBlock}`);
    
    // Get last 5 blocks
    console.log("\n📋 LAST 5 BLOCKS:");
    for (let i = Math.max(1, latestBlock - 4); i <= latestBlock; i++) {
        const block = await provider.getBlock(i);
        const txCount = block.transactions.length;
        const timestamp = new Date(block.timestamp * 1000).toLocaleTimeString();
        
        console.log(`   Block #${i}: ${txCount} transactions at ${timestamp}`);
        
        if (txCount > 0) {
            console.log(`     🔗 Block Hash: ${block.hash.substring(0, 10)}...`);
        }
    }
    
    console.log("\n✅ Blockchain is active and creating blocks!");
}

main().catch(console.error);