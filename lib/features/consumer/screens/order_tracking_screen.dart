import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _activeOrders = [
    {
      'id': 'ORD-2024-001',
      'status': 'Out for Delivery',
      'statusCode': 3,
      'items': [
        {'name': 'Alphonso Mango', 'quantity': 2, 'image': '🥭'},
        {'name': 'Red Onion', 'quantity': 3, 'image': '🧅'},
      ],
      'total': 975.0,
      'orderDate': '2024-01-15',
      'estimatedDelivery': '2024-01-16',
      'deliveryAddress': '123 Main Street, Mumbai, Maharashtra 400001',
      'paymentMethod': 'UPI',
    },
    {
      'id': 'ORD-2024-002',
      'status': 'Processing',
      'statusCode': 1,
      'items': [
        {'name': 'Fresh Milk', 'quantity': 1, 'image': '🥛'},
        {'name': 'Green Apple', 'quantity': 4, 'image': '🍏'},
      ],
      'total': 772.0,
      'orderDate': '2024-01-16',
      'estimatedDelivery': '2024-01-17',
      'deliveryAddress': '123 Main Street, Mumbai, Maharashtra 400001',
      'paymentMethod': 'Card',
    },
  ];

  final List<Map<String, dynamic>> _orderHistory = [
    {
      'id': 'ORD-2024-003',
      'status': 'Delivered',
      'statusCode': 4,
      'items': [
        {'name': 'Basmati Rice', 'quantity': 1, 'image': '🍚'},
        {'name': 'Turmeric Powder', 'quantity': 1, 'image': '🟡'},
      ],
      'total': 365.0,
      'orderDate': '2024-01-10',
      'deliveredDate': '2024-01-11',
      'deliveryAddress': '123 Main Street, Mumbai, Maharashtra 400001',
      'paymentMethod': 'UPI',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.consumerPrimary,
        foregroundColor: Colors.white,
        title: const Text('My Orders'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Active Orders'),
            Tab(text: 'Order History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildActiveOrders(), _buildOrderHistory()],
      ),
    );
  }

  Widget _buildActiveOrders() {
    if (_activeOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'No Active Orders',
        subtitle: 'Your current orders will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeOrders.length,
      itemBuilder: (context, index) =>
          _buildOrderCard(_activeOrders[index], true),
    );
  }

  Widget _buildOrderHistory() {
    if (_orderHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Order History',
        subtitle: 'Your completed orders will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orderHistory.length,
      itemBuilder: (context, index) =>
          _buildOrderCard(_orderHistory[index], false),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.consumerPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: AppColors.consumerPrimary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['id'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      color: _getStatusColor(order['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Order Items
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: order['items'].map<Widget>((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          item['image'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['name'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          'x${item['quantity']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Order Details
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ordered on ${order['orderDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  isActive ? Icons.access_time : Icons.check_circle,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  isActive
                      ? 'Expected by ${order['estimatedDelivery']}'
                      : 'Delivered on ${order['deliveredDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Order Total and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₹${order['total'].toInt()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.consumerPrimary,
                  ),
                ),
                Row(
                  children: [
                    if (isActive) ...[
                      TextButton(
                        onPressed: () => _showTrackingDetails(order),
                        child: const Text('Track Order'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    OutlinedButton(
                      onPressed: () => _showOrderDetails(order),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.consumerPrimary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: AppColors.consumerPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Progress Indicator for Active Orders
            if (isActive) ...[
              const SizedBox(height: 16),
              _buildProgressIndicator(order['statusCode']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    final steps = [
      'Order Placed',
      'Processing',
      'Packed',
      'Out for Delivery',
      'Delivered',
    ];

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? AppColors.consumerPrimary
                          : AppColors.textSecondary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : isCurrent
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step,
                    style: TextStyle(
                      fontSize: 8,
                      color: isCompleted || isCurrent
                          ? AppColors.consumerPrimary
                          : AppColors.textSecondary,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? AppColors.consumerPrimary
                        : AppColors.textSecondary.withOpacity(0.3),
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Order Placed':
        return AppColors.info;
      case 'Processing':
        return AppColors.warning;
      case 'Out for Delivery':
        return AppColors.consumerPrimary;
      case 'Delivered':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showTrackingDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Track Order ${order['id']}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery Address
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.consumerPrimary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delivery Address',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    order['deliveryAddress'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Detailed Progress
                      _buildDetailedProgress(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedProgress() {
    final trackingSteps = [
      {
        'title': 'Order Placed',
        'time': '2:30 PM, Jan 15',
        'description': 'Your order has been placed successfully',
        'completed': true,
      },
      {
        'title': 'Order Confirmed',
        'time': '2:45 PM, Jan 15',
        'description': 'Order confirmed by seller',
        'completed': true,
      },
      {
        'title': 'Packed',
        'time': '4:20 PM, Jan 15',
        'description': 'Your order has been packed',
        'completed': true,
      },
      {
        'title': 'Out for Delivery',
        'time': '10:30 AM, Jan 16',
        'description': 'Your order is on the way',
        'completed': true,
        'current': true,
      },
      {
        'title': 'Delivered',
        'time': 'Expected by 2:00 PM',
        'description': 'Order will be delivered soon',
        'completed': false,
      },
    ];

    return Column(
      children: trackingSteps.map((step) {
        final isCompleted = step['completed'] as bool;
        final isCurrent = step['current'] as bool? ?? false;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.consumerPrimary
                        : AppColors.textSecondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                if (trackingSteps.indexOf(step) < trackingSteps.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? AppColors.consumerPrimary
                        : AppColors.textSecondary.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCurrent
                                ? AppColors.consumerPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          step['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order details for ${order['id']}')));
  }
}
