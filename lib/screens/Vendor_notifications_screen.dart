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
  bool isPromotionalEnabled = true;
  
  final Color _primaryColor = const Color(0xFF673AB7); // Deep Purple
  final Color _bgColor = const Color(0xFF4A148C); // Darker Purple for background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Notifications', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize how you want to be notified',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
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
                    _buildGlassmorphicCard(
                      icon: Icons.campaign_outlined,
                      title: "Promotional Notifications",
                      subtitle: "Get offers and promotions",
                      value: isPromotionalEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          isPromotionalEnabled = value;
                        });
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Settings Saved!'),
                              backgroundColor: _primaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: _primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    color: Colors.black87, 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold
                  )
                ),
                Text(
                  subtitle, 
                  style: TextStyle(
                    color: Colors.black54, 
                    fontSize: 14
                  )
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _primaryColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

