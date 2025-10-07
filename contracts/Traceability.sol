// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ProductRegistry.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Traceability
 * @dev Manages QR code scanning and product traceability
 */
contract Traceability is Ownable, ReentrancyGuard {
    
    ProductRegistry public immutable productRegistry;
    
    struct ScanEvent {
        address scanner;
        ProductRegistry.UserRole scannerRole;
        uint256 timestamp;
        string location;
        string metaHash;
        bool verified;
    }
    
    struct TraceabilityRecord {
        string productId;
        string qrCodeHash;
        ScanEvent[] scanHistory;
        mapping(address => uint256) scanCount;
        bool isActive;
        uint256 createdAt;
    }
    
    // Mappings
    mapping(string => TraceabilityRecord) public traceabilityRecords;
    mapping(string => bool) public activeQRCodes;
    mapping(address => mapping(string => bool)) public hasScannedProduct;
    
    // Events
    event QRCodeScanned(
        string indexed productId,
        string indexed qrCodeHash,
        address indexed scanner,
        ProductRegistry.UserRole scannerRole,
        uint256 timestamp,
        string location
    );
    
    event TraceabilityRecordCreated(
        string indexed productId,
        string qrCodeHash,
        uint256 timestamp
    );
    
    event TraceabilityVerified(
        string indexed productId,
        address indexed verifier,
        uint256 timestamp
    );
    
    modifier validQRCode(string memory qrCodeHash) {
        require(activeQRCodes[qrCodeHash], "Invalid or inactive QR code");
        _;
    }
    
    modifier onlyRegisteredUser() {
        require(productRegistry.isUserRegistered(msg.sender), "User not registered");
        _;
    }
    
    constructor(address _productRegistry) {
        require(_productRegistry != address(0), "Invalid product registry address");
        productRegistry = ProductRegistry(_productRegistry);
    }
    
    /**
     * @dev Create traceability record for a product
     * Called automatically when product is registered
     */
    function createTraceabilityRecord(
        string memory productId,
        string memory qrCodeHash
    ) external onlyOwner {
        require(!activeQRCodes[qrCodeHash], "QR code already exists");
        require(bytes(productId).length > 0, "Product ID required");
        require(bytes(qrCodeHash).length > 0, "QR code hash required");
        
        TraceabilityRecord storage record = traceabilityRecords[qrCodeHash];
        record.productId = productId;
        record.qrCodeHash = qrCodeHash;
        record.isActive = true;
        record.createdAt = block.timestamp;
        
        activeQRCodes[qrCodeHash] = true;
        
        emit TraceabilityRecordCreated(productId, qrCodeHash, block.timestamp);
    }
    
    /**
     * @dev Record QR code scan
     */
    function recordScan(
        string memory qrCodeHash,
        string memory location,
        string memory metaHash
    ) external onlyRegisteredUser validQRCode(qrCodeHash) nonReentrant {
        TraceabilityRecord storage record = traceabilityRecords[qrCodeHash];
        
        require(record.isActive, "Traceability record not active");
        
        // Get scanner's role
        ProductRegistry.UserRole scannerRole = productRegistry.getUserRole(msg.sender);
        
        // Verify scanner is the current owner or next in chain
        ProductRegistry.Product memory product = productRegistry.getProduct(record.productId);
        require(
            product.currentOwner == msg.sender || 
            _isValidNextOwner(product.currentRole, scannerRole),
            "Not authorized to scan this product"
        );
        
        // Record the scan
        record.scanHistory.push(ScanEvent({
            scanner: msg.sender,
            scannerRole: scannerRole,
            timestamp: block.timestamp,
            location: location,
            metaHash: metaHash,
            verified: true
        }));
        
        // Update scan count
        record.scanCount[msg.sender]++;
        hasScannedProduct[msg.sender][record.productId] = true;
        
        emit QRCodeScanned(
            record.productId,
            qrCodeHash,
            msg.sender,
            scannerRole,
            block.timestamp,
            location
        );
    }
    
    /**
     * @dev Get complete trace for a product
     */
    function getTrace(string memory qrCodeHash) 
        external 
        view 
        validQRCode(qrCodeHash) 
        returns (
            string memory productId,
            ScanEvent[] memory scanHistory,
            bool isActive,
            uint256 createdAt
        ) 
    {
        TraceabilityRecord storage record = traceabilityRecords[qrCodeHash];
        
        return (
            record.productId,
            record.scanHistory,
            record.isActive,
            record.createdAt
        );
    }
    
    /**
     * @dev Get scan history for a specific product
     */
    function getProductTraceability(string memory productId) 
        external 
        view 
        returns (ScanEvent[] memory) 
    {
        // Find the QR code for this product
        string memory qrHash = _getQRHashForProduct(productId);
        require(bytes(qrHash).length > 0, "Product not found");
        
        return traceabilityRecords[qrHash].scanHistory;
    }
    
    /**
     * @dev Verify product authenticity by QR code
     */
    function verifyProductAuthenticity(string memory qrCodeHash) 
        external 
        view 
        validQRCode(qrCodeHash) 
        returns (
            bool isAuthentic,
            string memory productId,
            address originalFarmer,
            uint256 createdAt,
            uint256 totalScans
        ) 
    {
        TraceabilityRecord storage record = traceabilityRecords[qrCodeHash];
        ProductRegistry.Product memory product = productRegistry.getProduct(record.productId);
        
        isAuthentic = record.isActive && product.exists;
        productId = record.productId;
        originalFarmer = product.farmer;
        createdAt = record.createdAt;
        totalScans = record.scanHistory.length;
    }
    
    /**
     * @dev Get scan count for a user on a specific product
     */
    function getUserScanCount(address user, string memory qrCodeHash) 
        external 
        view 
        validQRCode(qrCodeHash) 
        returns (uint256) 
    {
        return traceabilityRecords[qrCodeHash].scanCount[user];
    }
    
    /**
     * @dev Check if user has scanned a product
     */
    function hasUserScannedProduct(address user, string memory productId) 
        external 
        view 
        returns (bool) 
    {
        return hasScannedProduct[user][productId];
    }
    
    /**
     * @dev Get current ownership chain for a product
     */
    function getOwnershipChain(string memory productId) 
        external 
        view 
        returns (
            address farmer,
            address distributor,
            address retailer,
            address consumer,
            ProductRegistry.UserRole currentRole
        ) 
    {
        ProductRegistry.Product memory product = productRegistry.getProduct(productId);
        ProductRegistry.OwnershipTransfer[] memory history = productRegistry.getOwnershipHistory(productId);
        
        farmer = product.farmer;
        currentRole = product.currentRole;
        
        // Parse ownership history
        for (uint i = 0; i < history.length; i++) {
            if (history[i].toRole == ProductRegistry.UserRole.Distributor) {
                distributor = history[i].to;
            } else if (history[i].toRole == ProductRegistry.UserRole.Retailer) {
                retailer = history[i].to;
            } else if (history[i].toRole == ProductRegistry.UserRole.Consumer) {
                consumer = history[i].to;
            }
        }
    }
    
    /**
     * @dev Deactivate QR code (for recalled products)
     */
    function deactivateQRCode(string memory qrCodeHash) 
        external 
        onlyOwner 
        validQRCode(qrCodeHash) 
    {
        traceabilityRecords[qrCodeHash].isActive = false;
        activeQRCodes[qrCodeHash] = false;
    }
    
    /**
     * @dev Check if next owner role is valid
     */
    function _isValidNextOwner(
        ProductRegistry.UserRole currentRole, 
        ProductRegistry.UserRole scannerRole
    ) private pure returns (bool) {
        if (currentRole == ProductRegistry.UserRole.Farmer && 
            scannerRole == ProductRegistry.UserRole.Distributor) return true;
        if (currentRole == ProductRegistry.UserRole.Distributor && 
            scannerRole == ProductRegistry.UserRole.Retailer) return true;
        if (currentRole == ProductRegistry.UserRole.Retailer && 
            scannerRole == ProductRegistry.UserRole.Consumer) return true;
        return false;
    }
    
    /**
     * @dev Helper function to get QR hash for a product
     * Note: In a real implementation, this would need a mapping
     */
    function _getQRHashForProduct(string memory productId) 
        private 
        view 
        returns (string memory) 
    {
        // This is a simplified implementation
        // In production, you'd maintain a productId -> qrHash mapping
        ProductRegistry.Product memory product = productRegistry.getProduct(productId);
        return product.qrCodeHash;
    }
    
    /**
     * @dev Emergency function to update product registry
     */
    function updateProductRegistry(address newRegistry) external onlyOwner {
        require(newRegistry != address(0), "Invalid registry address");
        // Note: This would require more complex migration logic in production
    }
}