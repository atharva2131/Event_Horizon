import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  // Deep purple color theme
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple
  final Color lightPurple = const Color(0xFFD1C4E9); // Light Purple
  final Color accentColor = const Color(0xFF9575CD); // Medium Purple
  
  late TabController _tabController;
  
  // Sample notifications data
  final List<Map<String, dynamic>> allNotifications = [
    {
      'title': 'Event Reminder',
      'message': 'Your event "Summer Wedding" starts in 1 hour!',
      'time': DateTime.now().subtract(const Duration(minutes: 30)),
      'type': 'reminder',
      'isRead': false,
    },
    {
      'title': 'Payment Received',
      'message': 'You received \$50 from John Doe for "Birthday Party Photography".',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'type': 'payment',
      'isRead': false,
    },
    {
      'title': 'New Message',
      'message': 'Alice sent you a message regarding your upcoming event.',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'type': 'message',
      'isRead': true,
    },
    {
      'title': 'Booking Confirmed',
      'message': 'Your booking for "Corporate Event" has been confirmed.',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'booking',
      'isRead': true,
    },
    {
      'title': 'Special Offer',
      'message': 'Get 20% off on your next booking! Use code SPECIAL20.',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'promotion',
      'isRead': false,
    },
    {
      'title': 'Booking Request',
      'message': 'You have a new booking request from Michael Brown for "Wedding Photography".',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'type': 'request',
      'isRead': true,
    },
    {
      'title': 'System Update',
      'message': 'Our app has been updated with new features. Check them out!',
      'time': DateTime.now().subtract(const Duration(days: 4)),
      'type': 'system',
      'isRead': true,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  List<Map<String, dynamic>> get _unreadNotifications {
    return allNotifications.where((notification) => notification['isRead'] == false).toList();
  }
  
  List<Map<String, dynamic>> get _readNotifications {
    return allNotifications.where((notification) => notification['isRead'] == true).toList();
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(time);
    }
  }
  
  IconData _getIconForType(String type) {
    switch (type) {
      case 'reminder':
        return Icons.alarm;
      case 'payment':
        return Icons.payment;
      case 'message':
        return Icons.message;
      case 'booking':
        return Icons.calendar_today;
      case 'promotion':
        return Icons.local_offer;
      case 'request':
        return Icons.book_online;
      case 'system':
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }
  
  Color _getColorForType(String type) {
    switch (type) {
      case 'reminder':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'message':
        return Colors.blue;
      case 'booking':
        return primaryColor;
      case 'promotion':
        return Colors.pink;
      case 'request':
        return Colors.teal;
      case 'system':
        return Colors.grey;
      default:
        return primaryColor;
    }
  }
  
  void _markAllAsRead() {
    setState(() {
      for (var notification in allNotifications) {
        notification['isRead'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  void _markAsRead(int index, List<Map<String, dynamic>> list) {
    setState(() {
      list[index]['isRead'] = true;
    });
  }
  
  void _deleteNotification(int index, List<Map<String, dynamic>> list) {
    setState(() {
      final notification = list[index];
      allNotifications.removeWhere((item) => 
        item['title'] == notification['title'] && 
        item['message'] == notification['message'] &&
        item['time'] == notification['time']
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _unreadNotifications.isEmpty ? null : _markAllAsRead,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'All (${allNotifications.length})'),
            Tab(text: 'Unread (${_unreadNotifications.length})'),
            Tab(text: 'Read (${_readNotifications.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All notifications tab
          _buildNotificationsList(allNotifications),
          
          // Unread notifications tab
          _buildNotificationsList(_unreadNotifications),
          
          // Read notifications tab
          _buildNotificationsList(_readNotifications),
        ],
      ),
    );
  }
  
  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key('${notification['title']}-${notification['time'].toString()}'),
          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.done, color: Colors.white),
          ),
          secondaryBackground: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              _deleteNotification(index, notifications);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notification deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            } else {
              _markAsRead(index, notifications);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Marked as read'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          child: _buildNotificationCard(notification, index),
        );
      },
    );
  }
  
  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final bool isRead = notification['isRead'];
    final Color typeColor = _getColorForType(notification['type']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isRead 
            ? Border.all(color: Colors.transparent) 
            : Border.all(color: primaryColor.withOpacity(0.3), width: 2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconForType(notification['type']), color: typeColor, size: 24),
            ),
            if (!isRead)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'],
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification['time']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'read',
              child: Row(
                children: [
                  Icon(
                    isRead ? Icons.mark_email_unread : Icons.done,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(isRead ? 'Mark as unread' : 'Mark as read'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'read') {
              setState(() {
                notification['isRead'] = !notification['isRead'];
              });
            } else if (value == 'delete') {
              _deleteNotification(index, allNotifications);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notification deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
        ),
        onTap: () {
          // Mark as read when tapped
          if (!isRead) {
            setState(() {
              notification['isRead'] = true;
            });
          }
          
          // Show notification details
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _buildNotificationDetails(notification),
          );
        },
      ),
    );
  }
  
  Widget _buildNotificationDetails(Map<String, dynamic> notification) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getColorForType(notification['type']).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(notification['type']),
                  color: _getColorForType(notification['type']),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTime(notification['time']),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            notification['message'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteNotification(
                    allNotifications.indexOf(notification),
                    allNotifications,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Notification deleted'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 70,
            color: lightPurple,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

