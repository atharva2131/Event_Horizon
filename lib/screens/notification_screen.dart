import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
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
            currentFilter = "vendor";
            break;
          case 2:
            currentFilter = "budget";
            break;
          case 3:
            currentFilter = "task";
            break;
        }
        _filterNotifications();
      });
    }
  }

  Future<void> _loadNotifications() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample notification data with the specific types mentioned
    final sampleNotifications = [
      // Vendor Confirmations
      {
        'id': '1',
        'title': 'Photographer Confirmed',
        'message': 'Your photographer "John Smith Photography" has confirmed the booking for March 15.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'isRead': false,
        'type': 'vendor',
        'actionable': true,
        'actionText': 'View Details',
        'priority': 'high',
        'eventName': 'Wedding Reception'
      },
      {
        'id': '2',
        'title': 'Caterer Confirmed',
        'message': 'Your caterer "Gourmet Delights" has confirmed the menu and booking for your event.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'isRead': true,
        'type': 'vendor',
        'actionable': true,
        'actionText': 'View Menu',
        'priority': 'medium',
        'eventName': 'Wedding Reception'
      },
      
      // Budget Alerts
      {
        'id': '3',
        'title': 'Budget Alert',
        'message': 'You\'re approaching your budget limit. You\'ve used 85% of your "Wedding Reception" budget.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        'isRead': false,
        'type': 'budget',
        'actionable': true,
        'actionText': 'Review Budget',
        'priority': 'high',
        'eventName': 'Wedding Reception'
      },
      {
        'id': '4',
        'title': 'New Expense Added',
        'message': 'A new expense of \$250 has been added to your "Birthday Party" budget for decorations.',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
        'type': 'budget',
        'actionable': true,
        'actionText': 'View Expense',
        'priority': 'medium',
        'eventName': 'Birthday Party'
      },
      
      // Task Reminders
      {
        'id': '5',
        'title': 'Venue Confirmation Due',
        'message': 'The venue confirmation for "Grand Plaza Hotel" is due today! Please confirm to secure your booking.',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'isRead': false,
        'type': 'task',
        'actionable': true,
        'actionText': 'Confirm Now',
        'priority': 'urgent',
        'eventName': 'Wedding Reception'
      },
      {
        'id': '6',
        'title': 'Send Invitations',
        'message': 'Reminder: You need to send out invitations for your "Birthday Party" by tomorrow.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
        'isRead': false,
        'type': 'task',
        'actionable': true,
        'actionText': 'Send Now',
        'priority': 'high',
        'eventName': 'Birthday Party'
      },
      {
        'id': '7',
        'title': 'Finalize Guest List',
        'message': 'Your guest list for "Corporate Event" needs to be finalized by the end of this week.',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'isRead': true,
        'type': 'task',
        'actionable': true,
        'actionText': 'Edit List',
        'priority': 'medium',
        'eventName': 'Corporate Event'
      },
      
      // Additional notifications
      {
        'id': '8',
        'title': 'DJ Availability Update',
        'message': 'Your preferred DJ is now available on your event date. Would you like to book them?',
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        'isRead': true,
        'type': 'vendor',
        'actionable': true,
        'actionText': 'Book Now',
        'priority': 'medium',
        'eventName': 'Wedding Reception'
      },
      {
        'id': '9',
        'title': 'Budget Savings Alert',
        'message': 'Good news! You\'ve saved \$300 on your "Corporate Event" by booking vendors early.',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'isRead': true,
        'type': 'budget',
        'actionable': false,
        'priority': 'low',
        'eventName': 'Corporate Event'
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
      case 'vendor':
        return Icons.store;
      case 'budget':
        return Icons.attach_money;
      case 'task':
        return Icons.assignment;
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
          'Notifications',
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
                Tab(text: 'Vendors'),
                Tab(text: 'Budget'),
                Tab(text: 'Tasks'),
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
            "Stay Updated",
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
                          const SizedBox(height: 4),
                          Text(
                            "Event: ${notification['eventName']}",
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
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
                              if (priority == 'urgent' || priority == 'high')
                                Row(
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      size: 14,
                                      color: priorityColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      priority.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: priorityColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
      case 'vendor':
        return Colors.purple;
      case 'budget':
        return Colors.green;
      case 'task':
        return Colors.blue;
      default:
        return primaryColor;
    }
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (currentFilter) {
      case 'vendor':
        message = "No vendor notifications";
        icon = Icons.store_outlined;
        break;
      case 'budget':
        message = "No budget alerts";
        icon = Icons.account_balance_wallet_outlined;
        break;
      case 'task':
        message = "No task reminders";
        icon = Icons.assignment_outlined;
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

