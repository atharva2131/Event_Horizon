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
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGlassmorphicCard(
              icon: Icons.email_outlined,
              title: "Email Notifications",
              subtitle: "Receive updates via email",
              value: isEmailEnabled,
              onChanged: (bool value) {
                setState(() {
                  isEmailEnabled = value;
                });
              },
            ),
            _buildGlassmorphicCard(
              icon: Icons.notifications_active_outlined,
              title: "Push Notifications",
              subtitle: "Get real-time alerts",
              value: isPushEnabled,
              onChanged: (bool value) {
                setState(() {
                  isPushEnabled = value;
                });
              },
            ),
            _buildGlassmorphicCard(
              icon: Icons.sms_outlined,
              title: "SMS Notifications",
              subtitle: "Receive messages for updates",
              value: isSMSPushEnabled,
              onChanged: (bool value) {
                setState(() {
                  isSMSPushEnabled = value;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings Saved!')),
                  );
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}
