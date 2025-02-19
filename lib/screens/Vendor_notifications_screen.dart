import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isEmailEnabled = true;
  bool isPushEnabled = true;
  bool isSMSPushEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Enable Email Notifications'),
              value: isEmailEnabled,
              onChanged: (bool value) {
                setState(() {
                  isEmailEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Enable Push Notifications'),
              value: isPushEnabled,
              onChanged: (bool value) {
                setState(() {
                  isPushEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Enable SMS Notifications'),
              value: isSMSPushEnabled,
              onChanged: (bool value) {
                setState(() {
                  isSMSPushEnabled = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save the notification preferences
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings Saved!')),
                );
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}