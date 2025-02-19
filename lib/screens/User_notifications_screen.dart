import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {'title': 'Event Reminder', 'message': 'Your event starts in 1 hour!'},
      {'title': 'Payment Received', 'message': 'You received \$50 from John Doe.'},
      {'title': 'New Message', 'message': 'Alice sent you a message.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(notifications[index]['title']!),
              subtitle: Text(notifications[index]['message']!),
              trailing: const Icon(Icons.notifications_active, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}
