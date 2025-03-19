import 'package:flutter/material.dart';

class VendorNotificationScreen extends StatefulWidget {
  const VendorNotificationScreen({super.key});

  @override
  _VendorNotificationScreenState createState() => _VendorNotificationScreenState();
}

class _VendorNotificationScreenState extends State<VendorNotificationScreen> with SingleTickerProviderStateMixin {
  // Define the deep purple color as a constant for consistent usage
  final Color primaryColor = Colors.deepPurple;
  final Color primaryLightColor = Colors.deepPurple[100]!;
  
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> filteredNotifications = [];
  bool isLoading = true;
  String currentFilter = "all";
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    // Simulate loading notifications
    _loadNotifications();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            currentFilter = "all";
            break;
          case 1:
            currentFilter = "booking";
            break;
          case 2:
            currentFilter = "payment";
            break;
          case 3:
            currentFilter = "review";
            break;
        }
        _filterNotifications();
      });
    }
  }

  Future<void> _loadNotifications() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample notification data with vendor-specific types
    final sampleNotifications = [
      // Booking Notifications
      {
        'id': '1',
        'title': 'New Booking Request',
        'message': 'James Watson has requested to book your photography services for March 15.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'isRead': false,
        'type': 'booking',
        'actionable': true,
        'actionText': 'Review Request',
        'priority': 'high',
        'clientName': 'James Watson',
        'eventType': 'Wedding Reception'
      },
      {
        'id': '2',
        'title': 'Booking Confirmed',
        'message': 'Your booking with Sarah Johnson for April 10 has been confirmed.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'isRead': true,
        'type': 'booking',
        'actionable': true,
        'actionText': 'View Details',
        'priority': 'medium',
        'clientName': 'Sarah Johnson',
        'eventType': 'Corporate Event'
      },
      {
        'id': '3',
        'title': 'Booking Canceled',
        'message': 'The booking with Michael Brown for June 20 has been canceled.',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': false,
        'type': 'booking',
        'actionable': false,
        'priority': 'medium',
        'clientName': 'Michael Brown',
        'eventType': 'Birthday Party'
      },
      
      // Payment Notifications
      {
        'id': '4',
        'title': 'Payment Received',
        'message': 'You\'ve received a payment of \$250 from Emily Davis for photography services.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        'isRead': false,
        'type': 'payment',
        'actionable': true,
        'actionText': 'View Transaction',
        'priority': 'medium',
        'clientName': 'Emily Davis',
        'eventType': 'Engagement Party',
        'amount': '\$250'
      },
      {
        'id': '5',
        'title': 'Payment Due Reminder',
        'message': 'A payment of \$350 from David Wilson is due in 2 days.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
        'isRead': false,
        'type': 'payment',
        'actionable': true,
        'actionText': 'Send Reminder',
        'priority': 'high',
        'clientName': 'David Wilson',
        'eventType': 'Wedding Reception',
        'amount': '\$350'
      },
      {
        'id': '6',
        'title': 'Payout Processed',
        'message': 'Your monthly payout of \$1,200 has been processed and will be deposited to your bank account.',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'isRead': true,
        'type': 'payment',
        'actionable': true,
        'actionText': 'View Statement',
        'priority': 'low',
        'amount': '\$1,200'
      },
      
      // Review Notifications
      {
        'id': '7',
        'title': 'New Review',
        'message': 'Jennifer Martinez has left a 5-star review for your services at her wedding.',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'isRead': false,
        'type': 'review',
        'actionable': true,
        'actionText': 'View Review',
        'priority': 'medium',
        'clientName': 'Jennifer Martinez',
        'eventType': 'Wedding',
        'rating': 5
      },
      {
        'id': '8',
        'title': 'Review Response Needed',
        'message': 'A client has left a 3-star review that requires your attention.',
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        'isRead': false,
        'type': 'review',
        'actionable': true,
        'actionText': 'Respond Now',
        'priority': 'urgent',
        'clientName': 'Robert Taylor',
        'eventType': 'Corporate Event',
        'rating': 3
      },
      
      // System Notifications
      {
        'id': '9',
        'title': 'Profile Verification',
        'message': 'Your business profile has been verified. You now have access to all vendor features.',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'isRead': true,
        'type': 'system',
        'actionable': false,
        'priority': 'low'
      },
      {
        'id': '10',
        'title': 'New Feature Available',
        'message': 'You can now offer package deals to your clients. Set up your first package today!',
        'timestamp': DateTime.now().subtract(const Duration(days: 4)),
        'isRead': true,
        'type': 'system',
        'actionable': true,
        'actionText': 'Set Up Packages',
        'priority': 'low'
      },
    ];
    
    setState(() {
      notifications = sampleNotifications;
      _filterNotifications();
      isLoading = false;
    });
  }
  
  void _filterNotifications() {
    if (currentFilter == "all") {
      filteredNotifications = List.from(notifications);
    } else {
      filteredNotifications = notifications.where((notification) => 
        notification['type'] == currentFilter
      ).toList();
    }
    
    // Sort by priority and timestamp
    filteredNotifications.sort((a, b) {
      // First sort by read status
      if (a['isRead'] != b['isRead']) {
        return a['isRead'] ? 1 : -1;
      }
      
      // Then by priority
      final priorityOrder = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};
      final aPriority = priorityOrder[a['priority']] ?? 4;
      final bPriority = priorityOrder[b['priority']] ?? 4;
      
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      
      // Finally by timestamp (newest first)
      return (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime);
    });
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      isLoading = true;
    });
    await _loadNotifications();
  }

  void _markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((notification) => notification['id'] == id);
      if (index != -1) {
        notifications[index]['isRead'] = true;
        _filterNotifications();
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
      _filterNotifications();
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((notification) => notification['id'] == id);
      _filterNotifications();
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return difference.inDays == 1 
          ? '1 day ago' 
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 
          ? '1 hour ago' 
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 
          ? '1 minute ago' 
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'payment':
        return Icons.attach_money;
      case 'review':
        return Icons.star;
      case 'system':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }
  
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Vendor Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (notifications.any((notification) => notification['isRead'] == false))
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Show options menu
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.done_all),
                      title: const Text('Mark all as read'),
                      onTap: () {
                        _markAllAsRead();
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_sweep),
                      title: const Text('Clear all notifications'),
                      onTap: () {
                        setState(() {
                          notifications = [];
                          _filterNotifications();
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Notification settings'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to notification settings
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Bookings'),
                Tab(text: 'Payments'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _refreshNotifications,
                        child: ListView.builder(
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _buildNotificationItem(notification);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final unreadCount = notifications.where((n) => n['isRead'] == false).length;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Business Updates",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unreadCount > 0 
                ? "You have $unreadCount unread notification${unreadCount > 1 ? 's' : ''}"
                : "You're all caught up!",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'] as bool;
    final String priority = notification['priority'] as String;
    final Color priorityColor = _getPriorityColor(priority);
    final bool isActionable = notification['actionable'] as bool;
    
    return Dismissible(
      key: Key(notification['id']),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
          // Show notification details or navigate to related screen
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isRead 
                ? null 
                : Border.all(color: priorityColor.withOpacity(0.7), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isRead && priority == 'urgent')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "URGENT - Action Required",
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getTypeColor(notification['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification['type']),
                        color: _getTypeColor(notification['type']),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: priorityColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          if (notification['clientName'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Client: ${notification['clientName']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (notification['eventType'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                "Event: ${notification['eventType']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryColor.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            notification['message'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getTimeAgo(notification['timestamp']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              if (notification['type'] == 'review' && notification['rating'] != null)
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < notification['rating'] ? Icons.star : Icons.star_border,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  }),
                                ),
                              if (notification['type'] == 'payment' && notification['amount'] != null && priority == 'high')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    notification['amount'],
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isActionable)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _markAsRead(notification['id']);
                        },
                        child: Text(
                          "Mark as Read",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Handle action button press
                          _markAsRead(notification['id']);
                          // Navigate to appropriate screen based on notification type
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getTypeColor(notification['type']),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(notification['actionText']),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getTypeColor(String type) {
    switch (type) {
      case 'booking':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'review':
        return Colors.amber[700]!;
      case 'system':
        return primaryColor;
      default:
        return primaryColor;
    }
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (currentFilter) {
      case 'booking':
        message = "No booking notifications";
        icon = Icons.calendar_today_outlined;
        break;
      case 'payment':
        message = "No payment notifications";
        icon = Icons.account_balance_wallet_outlined;
        break;
      case 'review':
        message = "No review notifications";
        icon = Icons.star_outline;
        break;
      default:
        message = "No notifications yet";
        icon = Icons.notifications_off_outlined;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: primaryLightColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll notify you when there's something new",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }
}

