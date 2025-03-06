import 'package:flutter/material.dart';
import 'package:eventhorizon/screens/Vendor_AccountSettingsScreen.dart';
import 'package:eventhorizon/screens/vendor_notifications_screen.dart';
import 'package:eventhorizon/screens/vendor_payment_methods_screen.dart';
import 'package:eventhorizon/screens/vendor_help_support_screen.dart';
import 'package:eventhorizon/screens/vendor_privacy_terms_screen.dart';

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

  // Define our theme colors
  final Color primaryColor = const Color(0xFF4A148C); // Deep Purple 900
  final Color accentColor = const Color(0xFF7C43BD); // Lighter purple
  final Color backgroundColor = Colors.white;
  final Color cardColor = const Color(0xFFF5F0FF); // Very light purple

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          'Vendor Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor, accentColor],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 40),
              child: Column(
                children: [
                  // Profile image with border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profilePicture),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(95 reviews)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatisticCard('7', 'Ongoing Orders', Icons.assignment),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatisticCard('\$35.6k', 'Earnings', Icons.attach_money),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatisticCard('4.8', 'Rating', Icons.star),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Active Collaborations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Collaborations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Collaborators list
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCollaborator('Sophia Lee', 'Florist', 'https://via.placeholder.com/150'),
                  _buildCollaborator('Daniel Smith', 'Lighting Expert', 'https://via.placeholder.com/150'),
                  _buildCollaborator('Emily Davis', 'Caterer', 'https://via.placeholder.com/150'),
                  _buildCollaborator('John Wilson', 'DJ', 'https://via.placeholder.com/150'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Settings & Preferences
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Settings & Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Settings options
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSettingOption(
                    'Account Settings',
                    Icons.person_outline,
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
                  _buildDivider(),
                  _buildSettingOption(
                    'Notifications',
                    Icons.notifications_outlined,
                    context,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsScreen())),
                  ),
                  _buildDivider(),
                  _buildSettingOption(
                    'Payment Methods',
                    Icons.credit_card_outlined,
                    context,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentMethodsScreen())),
                  ),
                  _buildDivider(),
                  _buildSettingOption(
                    'Help & Support',
                    Icons.help_outline,
                    context,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HelpSupportScreen())),
                  ),
                  _buildDivider(),
                  _buildSettingOption(
                    'Privacy & Terms',
                    Icons.privacy_tip_outlined,
                    context,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyTermsScreen())),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborator(String name, String role, String imageUrl) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            role,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(
      String title, IconData icon, BuildContext context, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
  
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 70,
      endIndent: 20,
      color: Colors.grey.shade200,
    );
  }
}