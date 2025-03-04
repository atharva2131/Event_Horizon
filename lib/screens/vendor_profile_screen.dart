import 'package:flutter/material.dart';
import 'Vendor_AccountSettingsScreen.dart';
import 'package:eventhorizon/screens/Vendor_notifications_screen.dart';
import 'package:eventhorizon/screens/Vendor_payment_methods_screen.dart';
import 'package:eventhorizon/screens/Vendor_help_support_screen.dart';
import 'package:eventhorizon/screens/Vendor_privacy_terms_screen.dart';
class VendorProfileScreen extends StatefulWidget {
  final int vendorIndex;
  

  const VendorProfileScreen({super.key, required this.vendorIndex});

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}
  
class _VendorProfileScreenState extends State<VendorProfileScreen> {
  String name = 'Michael Carter';
  String email = 'michael@example.com';
  String profilePicture = 'https://via.placeholder.com/150';

  void _updateProfile(
      String updatedName, String updatedEmail, String updatedPhoto) {
    setState(() {
      name = updatedName;
      email = updatedEmail;
      profilePicture = updatedPhoto;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profilePicture),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.star, color: Colors.amber),
                        Text('4.8 (95 reviews)',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Fix: Wrap statistics row in a SingleChildScrollView for horizontal scrolling
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatistic('7', 'Ongoing Orders'),
                    const SizedBox(width: 20), // Add spacing between items
                    _buildStatistic('\$35.6k', 'Earnings'),
                    const SizedBox(width: 20),
                    _buildStatistic('4.8', 'Client Rating'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Active Collaborations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Fix: Wrap Row in SingleChildScrollView to avoid overflow
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCollaborator('Sophia Lee', 'Florist',
                        'https://via.placeholder.com/150'),
                    _buildCollaborator('Daniel Smith', 'Lighting Expert',
                        'https://via.placeholder.com/150'),
                    _buildCollaborator('Emily Davis', 'Caterer',
                        'https://via.placeholder.com/150'),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
              const SizedBox(height: 20),

              const Text(
                'Settings & Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              _buildSettingOption(
                'Account Settings',
                context,
                () async {
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
                    _updateProfile(updatedData['name'], updatedData['email'],
                        updatedData['profilePicture']);
                  }
                },
              ),
              _buildSettingOption(
                'Notifications',
                context,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsScreen())),
              ),
              _buildSettingOption(
                'Payment Methods',
                context,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentMethodsScreen())),
              ),
              _buildSettingOption(
                'Help & Support',
                context,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HelpSupportScreen())),
              ),
              _buildSettingOption(
                'Privacy & Terms',
                context,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrivacyTermsScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistic(String value, String label) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 8.0), // Prevent tight spacing
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborator(String name, String role, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 8),
          Text(name),
          Text(role, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingOption(
      String title, BuildContext context, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
