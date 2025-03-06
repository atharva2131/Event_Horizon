import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'User_AccountSettingsScreen.dart';
import 'package:eventhorizon/screens/User_notifications_screen.dart';
import 'package:eventhorizon/screens/User_payment_methods_screen.dart';
import 'package:eventhorizon/screens/User_help_support_screen.dart';
import 'package:eventhorizon/screens/User_privacy_terms_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String name = 'John Doe';
  String email = 'john@example.com';
  String profilePicture = 'https://via.placeholder.com/150';

  // Deep purple color palette
  final Color primaryPurple = const Color(0xFF4A148C); // Deep Purple 900
  final Color lightPurple = const Color(0xFF7C43BD); // Lighter purple
  final Color accentPurple = const Color(0xFF9C27B0); // Purple 500
  final Color backgroundPurple = const Color(0xFFF5F0FF); // Very light purple

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryPurple)),
          content: Text('Are you sure you want to log out?', style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
  onPressed: () => _logout(context),
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryPurple, // FIXED: Replaced `primary` with `backgroundColor`
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  ),
  child: Text(
    'Logout',
    style: GoogleFonts.poppins(color: Colors.white),
  ),
),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [primaryPurple, accentPurple],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(),
                _buildStatisticsSection(),
                _buildFriendsSection(),
                _buildSettingsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(profilePicture),
            backgroundColor: lightPurple,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
          Text(
            email,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 5),
              Text(
                '4.9 (120 reviews)',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: backgroundPurple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatistic('25', 'Completed Events'),
          _buildStatistic('12', 'Upcoming Events'),
          _buildStatistic('4.9', 'User Rating'),
        ],
      ),
    );
  }

  Widget _buildFriendsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends & Connections',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 15),
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
            child: TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: GoogleFonts.poppins(color: accentPurple),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings & Preferences',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 15),
          _buildSettingOption('Notifications', Icons.notifications_none, () => _navigateTo(const NotificationsScreen())),
          _buildSettingOption('Payment Methods', Icons.credit_card, () => _navigateTo(const PaymentMethodsScreen())),
          _buildSettingOption('Help & Support', Icons.help_outline, () => _navigateTo(const HelpSupportScreen())),
          _buildSettingOption('Privacy & Terms', Icons.privacy_tip_outlined, () => _navigateTo(const PrivacyTermsScreen())),
        ],
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildStatistic(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryPurple,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFriend(String name, String role, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: lightPurple,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            role,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: accentPurple),
      title: Text(title, style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}