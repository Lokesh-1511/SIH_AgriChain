import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/agrichain_user.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'New Batch Available',
      message:
          'Fresh tomatoes batch from Krishna Farms is now available for bidding.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.batch,
      isRead: false,
      priority: NotificationPriority.high,
    ),
    NotificationItem(
      id: '2',
      title: 'Order Status Update',
      message: 'Your order #ORD001 has been shipped and is on its way.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.order,
      isRead: false,
      priority: NotificationPriority.medium,
    ),
    NotificationItem(
      id: '3',
      title: 'Price Alert',
      message: 'Mango prices have dropped by 15% in your area.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      type: NotificationType.price,
      isRead: true,
      priority: NotificationPriority.medium,
    ),
    NotificationItem(
      id: '4',
      title: 'Weather Advisory',
      message: 'Heavy rain expected in your region. Consider harvesting early.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.weather,
      isRead: true,
      priority: NotificationPriority.high,
    ),
    NotificationItem(
      id: '5',
      title: 'System Maintenance',
      message: 'Scheduled maintenance on Dec 15, 2024 from 2:00 AM to 4:00 AM.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.system,
      isRead: true,
      priority: NotificationPriority.low,
    ),
    NotificationItem(
      id: '6',
      title: 'New Features Available',
      message: 'Check out the new AI-powered crop advisory feature!',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.promotion,
      isRead: true,
      priority: NotificationPriority.low,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    Color primaryColor = _getPrimaryColorForRole(user?.role);

    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (unreadNotifications.isNotEmpty)
              Text(
                '${unreadNotifications.length} unread',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        elevation: 0,
        actions: [
          if (unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Notification Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: unreadNotifications.isNotEmpty
                  ? 'Unread (${unreadNotifications.length})'
                  : 'Unread',
            ),
            const Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Unread Tab
          unreadNotifications.isEmpty
              ? _buildEmptyState(
                  'No unread notifications',
                  Icons.notifications_none,
                )
              : _buildNotificationsList(unreadNotifications),

          // All Tab
          _notifications.isEmpty
              ? _buildEmptyState(
                  'No notifications yet',
                  Icons.notifications_none,
                )
              : _buildNotificationsList(_notifications),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationTile(notification);
      },
    );
  }

  Widget _buildNotificationTile(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? AppColors.border
              : Colors.blue.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getTypeColor(notification.type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: notification.isRead
                      ? FontWeight.w500
                      : FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (notification.priority == NotificationPriority.high)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HIGH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _onNotificationTap(notification),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'New notifications will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPrimaryColorForRole(UserRole? role) {
    if (role == null) return AppColors.consumerPrimary;
    
    switch (role) {
      case UserRole.farmer:
        return AppColors.farmerPrimary;
      case UserRole.distributor:
        return AppColors.distributorPrimary;
      case UserRole.retailer:
        return AppColors.retailerPrimary;
      case UserRole.consumer:
        return AppColors.consumerPrimary;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.batch:
        return AppColors.farmerPrimary;
      case NotificationType.order:
        return AppColors.distributorPrimary;
      case NotificationType.price:
        return AppColors.consumerPrimary;
      case NotificationType.weather:
        return AppColors.warning;
      case NotificationType.system:
        return AppColors.info;
      case NotificationType.promotion:
        return AppColors.success;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.batch:
        return Icons.inventory;
      case NotificationType.order:
        return Icons.local_shipping;
      case NotificationType.price:
        return Icons.trending_down;
      case NotificationType.weather:
        return Icons.cloud;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.promotion:
        return Icons.celebration;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onNotificationTap(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });

    // Handle notification action based on type
    switch (notification.type) {
      case NotificationType.batch:
        _showBatchDetails(notification);
        break;
      case NotificationType.order:
        _showOrderDetails(notification);
        break;
      case NotificationType.price:
        _showPriceDetails(notification);
        break;
      case NotificationType.weather:
        _showWeatherDetails(notification);
        break;
      case NotificationType.system:
        _showSystemDetails(notification);
        break;
      case NotificationType.promotion:
        _showPromotionDetails(notification);
        break;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'clear':
        _showClearAllDialog();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Detail methods for different notification types
  void _showBatchDetails(NotificationItem notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Batch details screen coming soon!')),
    );
  }

  void _showOrderDetails(NotificationItem notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order details screen coming soon!')),
    );
  }

  void _showPriceDetails(NotificationItem notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Price details screen coming soon!')),
    );
  }

  void _showWeatherDetails(NotificationItem notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Weather details screen coming soon!')),
    );
  }

  void _showSystemDetails(NotificationItem notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System details screen coming soon!')),
    );
  }

  void _showPromotionDetails(NotificationItem notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Promotion details screen coming soon!')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Data Models
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;
  final NotificationPriority priority;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.priority = NotificationPriority.medium,
  });
}

enum NotificationType { batch, order, price, weather, system, promotion }

enum NotificationPriority { low, medium, high }
