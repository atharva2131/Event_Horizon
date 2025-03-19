import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static const String _userNotificationsKey = 'user_notifications';
  static const String _vendorNotificationsKey = 'vendor_notifications';
  
  // Get user notifications from local storage
  static Future<List<Map<String, dynamic>>> getUserNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_userNotificationsKey);
    
    if (notificationsJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = json.decode(notificationsJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error decoding user notifications: $e');
      return [];
    }
  }
  
  // Get vendor notifications from local storage
  static Future<List<Map<String, dynamic>>> getVendorNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_vendorNotificationsKey);
    
    if (notificationsJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = json.decode(notificationsJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error decoding vendor notifications: $e');
      return [];
    }
  }
  
  // Save user notifications to local storage
  static Future<void> saveUserNotifications(List<Map<String, dynamic>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNotificationsKey, json.encode(notifications));
  }
  
  // Save vendor notifications to local storage
  static Future<void> saveVendorNotifications(List<Map<String, dynamic>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vendorNotificationsKey, json.encode(notifications));
  }
  
  // Mark a user notification as read
  static Future<void> markUserNotificationAsRead(String id) async {
    final notifications = await getUserNotifications();
    final index = notifications.indexWhere((notification) => notification['id'] == id);
    
    if (index != -1) {
      notifications[index]['isRead'] = true;
      await saveUserNotifications(notifications);
    }
  }
  
  // Mark a vendor notification as read
  static Future<void> markVendorNotificationAsRead(String id) async {
    final notifications = await getVendorNotifications();
    final index = notifications.indexWhere((notification) => notification['id'] == id);
    
    if (index != -1) {
      notifications[index]['isRead'] = true;
      await saveVendorNotifications(notifications);
    }
  }
  
  // Get unread notification count for badge display
  static Future<int> getUnreadUserNotificationCount() async {
    final notifications = await getUserNotifications();
    return notifications.where((notification) => notification['isRead'] == false).length;
  }
  
  static Future<int> getUnreadVendorNotificationCount() async {
    final notifications = await getVendorNotifications();
    return notifications.where((notification) => notification['isRead'] == false).length;
  }
  
  // Add a new notification (for testing purposes)
  static Future<void> addUserNotification(Map<String, dynamic> notification) async {
    final notifications = await getUserNotifications();
    notifications.insert(0, notification);
    await saveUserNotifications(notifications);
  }
  
  static Future<void> addVendorNotification(Map<String, dynamic> notification) async {
    final notifications = await getVendorNotifications();
    notifications.insert(0, notification);
    await saveVendorNotifications(notifications);
  }
}

// Widget to display notification badge on icons
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color color;
  
  const NotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.color = Colors.red,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

