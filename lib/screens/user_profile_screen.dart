import 'package:flutter/material.dart';
import 'User_AccountSettingsScreen.dart';
import 'package:eventhorizon/screens/User_notifications_screen.dart';
import 'package:eventhorizon/screens/User_payment_methods_screen.dart';
import 'package:eventhorizon/screens/User_help_support_screen.dart';
import 'package:eventhorizon/screens/User_privacy_terms_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String name = 'John Doe';
  String email = 'john@example.com';
  String profilePicture = 'https://via.placeholder.com/150';

  void _updateProfile(String updatedName, String updatedEmail, String updatedPhoto) {
    setState(() {
      name = updatedName;
      email = updatedEmail;
      profilePicture = updatedPhoto;
    });
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform logout actions
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            _buildStatisticsSection(),
            _buildFriendsSection(),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(radius: 50, backgroundImage: NetworkImage(profilePicture)),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 5),
            Text('4.9 (120 reviews)', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatistic('25', 'Completed Events'),
        _buildStatistic('12', 'Upcoming Events'),
        _buildStatistic('4.9', 'User Rating'),
      ],
    );
  }

  Widget _buildFriendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('Friends & Connections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFriend('Alice Brown', 'Event Planner', 'https://via.placeholder.com/150'),
              _buildFriend('Mark Wilson', 'Photographer', 'https://via.placeholder.com/150'),
              _buildFriend('Emma Johnson', 'Musician', 'https://via.placeholder.com/150'),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: () {}, child: const Text('See All')),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Settings & Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        _buildSettingOption('Account Settings', () async {
          final updatedData = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountSettingsScreen(
                name: name,
                email: email,
                profilePicture: profilePicture,
              ),
            ),
          );
          if (updatedData != null) {
            _updateProfile(updatedData['name'], updatedData['email'], updatedData['profilePicture']);
          }
        }),
        _buildSettingOption('Notifications', () => _navigateTo(const NotificationsScreen())),
        _buildSettingOption('Payment Methods', () => _navigateTo(const PaymentMethodsScreen())),
        _buildSettingOption('Help & Support', () => _navigateTo(const HelpSupportScreen())),
        _buildSettingOption('Privacy & Terms', () => _navigateTo(const PrivacyTermsScreen())),
        const SizedBox(height: 20),
      ],
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildStatistic(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFriend(String name, String role, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 14)),
          Text(role, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
