// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title ProductRegistry
 * @dev Handles product registration, QR generation, and ownership transfers
 */
contract ProductRegistry is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    
    Counters.Counter private _productCounter;
    
    enum UserRole { Farmer, Distributor, Retailer, Consumer }
    
    struct Product {
        string productId;
        string productName;
        uint256 basePrice;
        address farmer;
        address currentOwner;
        UserRole currentRole;
        uint256 createdAt;
        bool exists;
        string qrCodeHash;
    }
    
    struct OwnershipTransfer {
        address from;
        address to;
        UserRole fromRole;
        UserRole toRole;
        uint256 timestamp;
        uint256 additionalCost;
        string metaHash; // IPFS hash for metadata
        string location;
    }
    
    // Mappings
    mapping(string => Product) public products;
    mapping(string => OwnershipTransfer[]) public ownershipHistory;
    mapping(address => UserRole) public userRoles;
    mapping(address => bool) public registeredUsers;
    mapping(string => bool) public productExists;
    
    // Events
    event ProductRegistered(
        string indexed productId,
        string productName,
        uint256 basePrice,
        address indexed farmer,
        string qrCodeHash
    );
    
    event OwnershipTransferred(
        string indexed productId,
        address indexed from,
        address indexed to,
        UserRole fromRole,
        UserRole toRole,
        uint256 additionalCost,
        string metaHash
    );
    
    event UserRegistered(address indexed user, UserRole role);
    
    modifier onlyRegisteredUser() {
        require(registeredUsers[msg.sender], "User not registered");
        _;
    }
    
    modifier onlyValidRole(UserRole role) {
        require(userRoles[msg.sender] == role, "Invalid role for this operation");
        _;
    }
    
    modifier productExistsModifier(string memory productId) {
        require(productExists[productId], "Product does not exist");
        _;
    }
    
    constructor() {}
    
    /**
     * @dev Register a new user with their role
     */
    function registerUser(address user, UserRole role) external onlyOwner {
        require(!registeredUsers[user], "User already registered");
        
        userRoles[user] = role;
        registeredUsers[user] = true;
        
        emit UserRegistered(user, role);
    }
    
    /**
     * @dev Register a new product (Farmer only)
     */
    function registerProduct(
        string memory productId,
        string memory productName,
        uint256 basePrice,
        string memory qrCodeHash
    ) external onlyRegisteredUser onlyValidRole(UserRole.Farmer) {
        require(!productExists[productId], "Product already exists");
        require(basePrice > 0, "Base price must be greater than 0");
        require(bytes(productName).length > 0, "Product name required");
        require(bytes(qrCodeHash).length > 0, "QR code hash required");
        
        _productCounter.increment();
        
        products[productId] = Product({
            productId: productId,
            productName: productName,
            basePrice: basePrice,
            farmer: msg.sender,
            currentOwner: msg.sender,
            currentRole: UserRole.Farmer,
            createdAt: block.timestamp,
            exists: true,
            qrCodeHash: qrCodeHash
        });
        
        productExists[productId] = true;
        
        emit ProductRegistered(productId, productName, basePrice, msg.sender, qrCodeHash);
    }
    
    /**
     * @dev Transfer ownership of a product
     */
    function transferOwnership(
        string memory productId,
        address newOwner,
        UserRole newRole,
        uint256 additionalCost,
        string memory metaHash,
        string memory location
    ) external onlyRegisteredUser productExistsModifier(productId) nonReentrant {
        Product storage product = products[productId];
        
        require(product.currentOwner == msg.sender, "Only current owner can transfer");
        require(registeredUsers[newOwner], "New owner not registered");
        require(userRoles[newOwner] == newRole, "Role mismatch for new owner");
        require(_isValidRoleTransition(product.currentRole, newRole), "Invalid role transition");
        
        // Record ownership transfer
        ownershipHistory[productId].push(OwnershipTransfer({
            from: msg.sender,
            to: newOwner,
            fromRole: product.currentRole,
            toRole: newRole,
            timestamp: block.timestamp,
            additionalCost: additionalCost,
            metaHash: metaHash,
            location: location
        }));
        
        // Update product ownership
        product.currentOwner = newOwner;
        product.currentRole = newRole;
        
        emit OwnershipTransferred(
            productId,
            msg.sender,
            newOwner,
            product.currentRole,
            newRole,
            additionalCost,
            metaHash
        );
    }
    
    /**
     * @dev Get product details
     */
    function getProduct(string memory productId) 
        external 
        view 
        productExistsModifier(productId) 
        returns (Product memory) 
    {
        return products[productId];
    }
    
    /**
     * @dev Get ownership history for a product
     */
    function getOwnershipHistory(string memory productId) 
        external 
        view 
        productExistsModifier(productId) 
        returns (OwnershipTransfer[] memory) 
    {
        return ownershipHistory[productId];
    }
    
    /**
     * @dev Get total cost for a product (base + all additional costs)
     */
    function getTotalProductCost(string memory productId) 
        external 
        view 
        productExistsModifier(productId) 
        returns (uint256) 
    {
        Product memory product = products[productId];
        uint256 totalCost = product.basePrice;
        
        OwnershipTransfer[] memory history = ownershipHistory[productId];
        for (uint i = 0; i < history.length; i++) {
            totalCost += history[i].additionalCost;
        }
        
        return totalCost;
    }
    
    /**
     * @dev Get cost breakdown for a product
     */
    function getCostBreakdown(string memory productId) 
        external 
        view 
        productExistsModifier(productId) 
        returns (
            uint256 farmerCost,
            uint256 distributorCost,
            uint256 retailerCost,
            uint256 totalCost
        ) 
    {
        Product memory product = products[productId];
        farmerCost = product.basePrice;
        distributorCost = 0;
        retailerCost = 0;
        
        OwnershipTransfer[] memory history = ownershipHistory[productId];
        for (uint i = 0; i < history.length; i++) {
            if (history[i].toRole == UserRole.Distributor) {
                distributorCost = history[i].additionalCost;
            } else if (history[i].toRole == UserRole.Retailer) {
                retailerCost = history[i].additionalCost;
            }
        }
        
        totalCost = farmerCost + distributorCost + retailerCost;
    }
    
    /**
     * @dev Check if role transition is valid
     */
    function _isValidRoleTransition(UserRole from, UserRole to) private pure returns (bool) {
        if (from == UserRole.Farmer && to == UserRole.Distributor) return true;
        if (from == UserRole.Distributor && to == UserRole.Retailer) return true;
        if (from == UserRole.Retailer && to == UserRole.Consumer) return true;
        return false;
    }
    
    /**
     * @dev Get user role
     */
    function getUserRole(address user) external view returns (UserRole) {
        require(registeredUsers[user], "User not registered");
        return userRoles[user];
    }
    
    /**
     * @dev Check if user is registered
     */
    function isUserRegistered(address user) external view returns (bool) {
        return registeredUsers[user];
    }
    
    /**
     * @dev Get total number of products
     */
    function getTotalProducts() external view returns (uint256) {
        return _productCounter.current();
    }
}