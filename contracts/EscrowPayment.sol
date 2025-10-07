// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ProductRegistry.sol";
import "./Traceability.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title EscrowPayment
 * @dev Manages automated payment distribution with escrow functionality
 */
contract EscrowPayment is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    
    ProductRegistry public immutable productRegistry;
    Traceability public immutable traceability;
    Counters.Counter private _orderCounter;
    
    enum OrderStatus { Created, Paid, Delivered, Released, Cancelled, Disputed }
    
    struct Order {
        string orderId;
        string productId;
        address consumer;
        address farmer;
        address distributor;
        address retailer;
        uint256 totalAmount;
        uint256 farmerAmount;
        uint256 distributorAmount;
        uint256 retailerAmount;
        OrderStatus status;
        uint256 createdAt;
        uint256 paidAt;
        uint256 deliveredAt;
        uint256 releasedAt;
        bool escrowReleased;
        string qrCodeHash;
    }
    
    struct PaymentBreakdown {
        uint256 farmerShare;
        uint256 distributorShare;
        uint256 retailerShare;
        uint256 totalAmount;
    }
    
    // Mappings
    mapping(string => Order) public orders;
    mapping(string => bool) public orderExists;
    mapping(address => string[]) public userOrders;
    mapping(string => address) public productToConsumer;
    
    // Events
    event OrderCreated(
        string indexed orderId,
        string indexed productId,
        address indexed consumer,
        uint256 totalAmount,
        PaymentBreakdown breakdown
    );
    
    event PaymentReceived(
        string indexed orderId,
        address indexed consumer,
        uint256 amount,
        uint256 timestamp
    );
    
    event PaymentReleased(
        string indexed orderId,
        address indexed farmer,
        address indexed distributor,
        address retailer,
        uint256 farmerAmount,
        uint256 distributorAmount,
        uint256 retailerAmount,
        uint256 timestamp
    );
    
    event OrderDelivered(
        string indexed orderId,
        address indexed consumer,
        string qrCodeHash,
        uint256 timestamp
    );
    
    event OrderCancelled(
        string indexed orderId,
        address indexed consumer,
        uint256 refundAmount,
        uint256 timestamp
    );
    
    modifier validOrder(string memory orderId) {
        require(orderExists[orderId], "Order does not exist");
        _;
    }
    
    modifier onlyConsumer(string memory orderId) {
        require(orders[orderId].consumer == msg.sender, "Only order consumer can perform this action");
        _;
    }
    
    modifier onlyRegisteredUser() {
        require(productRegistry.isUserRegistered(msg.sender), "User not registered");
        _;
    }
    
    constructor(address _productRegistry, address _traceability) {
        require(_productRegistry != address(0), "Invalid product registry address");
        require(_traceability != address(0), "Invalid traceability address");
        
        productRegistry = ProductRegistry(_productRegistry);
        traceability = Traceability(_traceability);
    }
    
    /**
     * @dev Create a new order with escrow payment
     */
    function createOrder(
        string memory orderId,
        string memory productId,
        address farmer,
        address distributor,
        address retailer
    ) external payable onlyRegisteredUser nonReentrant {
        require(!orderExists[orderId], "Order already exists");
        require(msg.value > 0, "Payment amount must be greater than 0");
        require(bytes(productId).length > 0, "Product ID required");
        
        // Verify product exists and get cost breakdown
        ProductRegistry.Product memory product = productRegistry.getProduct(productId);
        require(product.exists, "Product does not exist");
        
        // Get dynamic cost breakdown from product registry
        (
            uint256 farmerCost,
            uint256 distributorCost,
            uint256 retailerCost,
            uint256 totalCost
        ) = productRegistry.getCostBreakdown(productId);
        
        require(msg.value >= totalCost, "Insufficient payment amount");
        
        // Verify role assignments
        require(productRegistry.getUserRole(farmer) == ProductRegistry.UserRole.Farmer, "Invalid farmer");
        require(productRegistry.getUserRole(distributor) == ProductRegistry.UserRole.Distributor, "Invalid distributor");
        require(productRegistry.getUserRole(retailer) == ProductRegistry.UserRole.Retailer, "Invalid retailer");
        require(productRegistry.getUserRole(msg.sender) == ProductRegistry.UserRole.Consumer, "Only consumers can create orders");
        
        _orderCounter.increment();
        
        // Create order
        orders[orderId] = Order({
            orderId: orderId,
            productId: productId,
            consumer: msg.sender,
            farmer: farmer,
            distributor: distributor,
            retailer: retailer,
            totalAmount: msg.value,
            farmerAmount: farmerCost,
            distributorAmount: distributorCost,
            retailerAmount: retailerCost,
            status: OrderStatus.Paid,
            createdAt: block.timestamp,
            paidAt: block.timestamp,
            deliveredAt: 0,
            releasedAt: 0,
            escrowReleased: false,
            qrCodeHash: product.qrCodeHash
        });
        
        orderExists[orderId] = true;
        userOrders[msg.sender].push(orderId);
        productToConsumer[productId] = msg.sender;
        
        PaymentBreakdown memory breakdown = PaymentBreakdown({
            farmerShare: farmerCost,
            distributorShare: distributorCost,
            retailerShare: retailerCost,
            totalAmount: msg.value
        });
        
        emit OrderCreated(orderId, productId, msg.sender, msg.value, breakdown);
        emit PaymentReceived(orderId, msg.sender, msg.value, block.timestamp);
    }
    
    /**
     * @dev Consumer confirms delivery and triggers payment release
     */
    function confirmDeliveryAndRelease(
        string memory orderId,
        string memory qrCodeHash
    ) external validOrder(orderId) onlyConsumer(orderId) nonReentrant {
        Order storage order = orders[orderId];
        
        require(order.status == OrderStatus.Paid, "Order not in paid status");
        require(!order.escrowReleased, "Payment already released");
        require(keccak256(bytes(order.qrCodeHash)) == keccak256(bytes(qrCodeHash)), "QR code mismatch");
        
        // Verify consumer has scanned the product (traceability verification)
        require(
            traceability.hasUserScannedProduct(msg.sender, order.productId),
            "Consumer must scan product QR code first"
        );
        
        // Update order status
        order.status = OrderStatus.Delivered;
        order.deliveredAt = block.timestamp;
        
        emit OrderDelivered(orderId, msg.sender, qrCodeHash, block.timestamp);
        
        // Automatically release payment
        _releasePayment(orderId);
    }
    
    /**
     * @dev Internal function to release payment to all stakeholders
     */
    function _releasePayment(string memory orderId) internal {
        Order storage order = orders[orderId];
        
        require(order.status == OrderStatus.Delivered, "Order not delivered");
        require(!order.escrowReleased, "Payment already released");
        
        // Calculate any excess amount
        uint256 totalDistributed = order.farmerAmount + order.distributorAmount + order.retailerAmount;
        uint256 excess = order.totalAmount - totalDistributed;
        
        // Transfer payments
        if (order.farmerAmount > 0) {
            payable(order.farmer).transfer(order.farmerAmount);
        }
        
        if (order.distributorAmount > 0) {
            payable(order.distributor).transfer(order.distributorAmount);
        }
        
        if (order.retailerAmount > 0) {
            payable(order.retailer).transfer(order.retailerAmount);
        }
        
        // Return any excess to consumer
        if (excess > 0) {
            payable(order.consumer).transfer(excess);
        }
        
        // Update order status
        order.status = OrderStatus.Released;
        order.escrowReleased = true;
        order.releasedAt = block.timestamp;
        
        emit PaymentReleased(
            orderId,
            order.farmer,
            order.distributor,
            order.retailer,
            order.farmerAmount,
            order.distributorAmount,
            order.retailerAmount,
            block.timestamp
        );
    }
    
    /**
     * @dev Cancel order and refund consumer (only if not delivered)
     */
    function cancelOrder(string memory orderId) 
        external 
        validOrder(orderId) 
        onlyConsumer(orderId) 
        nonReentrant 
    {
        Order storage order = orders[orderId];
        
        require(order.status == OrderStatus.Paid, "Cannot cancel order at current status");
        require(!order.escrowReleased, "Cannot cancel after payment release");
        
        // Refund consumer
        payable(order.consumer).transfer(order.totalAmount);
        
        // Update order status
        order.status = OrderStatus.Cancelled;
        
        emit OrderCancelled(orderId, order.consumer, order.totalAmount, block.timestamp);
    }
    
    /**
     * @dev Get order details
     */
    function getOrder(string memory orderId) 
        external 
        view 
        validOrder(orderId) 
        returns (Order memory) 
    {
        return orders[orderId];
    }
    
    /**
     * @dev Get payment breakdown for an order
     */
    function getPaymentBreakdown(string memory orderId) 
        external 
        view 
        validOrder(orderId) 
        returns (PaymentBreakdown memory) 
    {
        Order memory order = orders[orderId];
        
        return PaymentBreakdown({
            farmerShare: order.farmerAmount,
            distributorShare: order.distributorAmount,
            retailerShare: order.retailerAmount,
            totalAmount: order.totalAmount
        });
    }
    
    /**
     * @dev Get user's orders
     */
    function getUserOrders(address user) external view returns (string[] memory) {
        return userOrders[user];
    }
    
    /**
     * @dev Verify consumer order for QR code scanning
     */
    function verifyConsumerOrder(
        address consumer,
        string memory productId,
        string memory qrCodeHash
    ) external view returns (
        bool isValid,
        string memory orderId,
        uint256 totalAmount,
        OrderStatus status
    ) {
        // Find order for this consumer and product
        string[] memory consumerOrders = userOrders[consumer];
        
        for (uint i = 0; i < consumerOrders.length; i++) {
            Order memory order = orders[consumerOrders[i]];
            
            if (keccak256(bytes(order.productId)) == keccak256(bytes(productId)) &&
                keccak256(bytes(order.qrCodeHash)) == keccak256(bytes(qrCodeHash)) &&
                order.consumer == consumer) {
                
                return (
                    true,
                    order.orderId,
                    order.totalAmount,
                    order.status
                );
            }
        }
        
        return (false, "", 0, OrderStatus.Cancelled);
    }
    
    /**
     * @dev Emergency withdrawal (only owner)
     */
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    /**
     * @dev Get contract balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Get total number of orders
     */
    function getTotalOrders() external view returns (uint256) {
        return _orderCounter.current();
    }
    
    /**
     * @dev Check if product has active order
     */
    function hasActiveOrder(string memory productId) external view returns (bool) {
        return productToConsumer[productId] != address(0);
    }
    
    /**
     * @dev Get consumer for a product
     */
    function getProductConsumer(string memory productId) external view returns (address) {
        return productToConsumer[productId];
    }
}