import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventhorizon/screens/User_AccountSettingsScreen.dart';
import 'package:eventhorizon/screens/User_notifications_screen.dart';
import 'package:eventhorizon/screens/User_payment_methods_screen.dart';
import 'package:eventhorizon/screens/User_help_support_screen.dart';
import 'package:eventhorizon/screens/User_privacy_terms_screen.dart';
import 'package:eventhorizon/screens/SignInPage.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Deep purple color palette
  final Color primaryPurple = const Color(0xFF4A148C); // Deep Purple 900
  final Color lightPurple = const Color(0xFF7C43BD); // Lighter purple
  final Color accentPurple = const Color(0xFF9C27B0); // Purple 500
  final Color backgroundPurple = const Color(0xFFF5F0FF); // Very light purple

  Map<String, dynamic> userProfile = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Get initials from name
  String getInitials(String name) {
    if (name.isEmpty) return "?";
    
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        setState(() {
          errorMessage = 'Authentication token not found. Please login again.';
          isLoading = false;
        });
        return;
      }
      
      // Use the correct API URL - adjust this to your actual backend URL
      final response = await http.get(
        Uri.parse('http://192.168.29.168:3000/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          userProfile = responseData['user'] ?? {};
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Handle unauthorized - token expired
        _handleSessionExpired();
      } else {
        setState(() {
          errorMessage = 'Failed to load profile: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading profile: $e';
        isLoading = false;
      });
    }
  }

  void _handleSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userData');
    
    if (!mounted) return;
    
    // Show message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your session has expired. Please login again.')),
    );
    
    // Navigate to login screen
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _updateProfile(String updatedName, String updatedEmail, String updatedPhoto) async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        setState(() {
          errorMessage = 'Authentication token not found. Please login again.';
          isLoading = false;
        });
        return;
      }
      
      // Use the correct API URL and method
      final response = await http.put(
        Uri.parse('http://192.168.29.168:3000/api/auth/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': updatedName,
          'email': updatedEmail,
          'avatar_url': updatedPhoto,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          userProfile = responseData['user'] ?? {};
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else if (response.statusCode == 401) {
        _handleSessionExpired();
      } else {
        setState(() {
          errorMessage = 'Failed to update profile: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error updating profile: $e';
        isLoading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      // Call logout API endpoint
      if (token != null) {
        try {
          await http.post(
            Uri.parse('http://192.168.29.168:3000/api/auth/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        } catch (e) {
          // Continue with local logout even if API call fails
          print('Error calling logout API: $e');
        }
      }
      
      // Clear local storage
      await prefs.remove('token');
      await prefs.remove('userData');
      
      // Navigate to login screen - use MaterialPageRoute to avoid route issues
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInPage(isUser: true)),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
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
                          onPressed: () => _showLogoutDialog(context),
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

  void _showLogoutDialog(BuildContext context) {
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
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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

  Widget _buildProfileHeader() {
    final String userName = userProfile['name'] ?? 'User Name';
    final String userInitials = getInitials(userName);
    final String? profileImageUrl = userProfile['profileImage'];
    final bool hasProfileImage = profileImageUrl != null && profileImageUrl.isNotEmpty && profileImageUrl != "null";

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: lightPurple,
            backgroundImage: hasProfileImage ? NetworkImage(profileImageUrl!) : null,
            child: !hasProfileImage ? Text(
              userInitials,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ) : null,
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
          Text(
            userProfile['email'] ?? 'user@example.com',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
          if (userProfile['phone'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                userProfile['phone'],
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 5),
              Text(
                '${userProfile['rating'] ?? '0'} (${userProfile['reviews_count'] ?? '0'} reviews)',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountSettingsScreen(
                    name: userProfile['name'] ?? '',
                    email: userProfile['email'] ?? '',
                    profilePicture: userProfile['profileImage'] ?? '',
                  ),
                ),
              );
              if (result != null) {
                _updateProfile(
                  result['name'], 
                  result['email'], 
                  result['profilePicture']
                );
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
          _buildStatistic(userProfile['completed_events']?.toString() ?? '0', 'Completed Events'),
          _buildStatistic(userProfile['upcoming_events']?.toString() ?? '0', 'Upcoming Events'),
          _buildStatistic(userProfile['rating']?.toString() ?? '0', 'User Rating'),
        ],
      ),
    );
  }

  Widget _buildFriendsSection() {
    // This would ideally be fetched from the backend
    List<Map<String, String>> friends = [
      {'name': 'Alice Brown', 'role': 'Event Planner', 'image': 'https://via.placeholder.com/150'},
      {'name': 'Mark Wilson', 'role': 'Photographer', 'image': 'https://via.placeholder.com/150'},
      {'name': 'Emma Johnson', 'role': 'Musician', 'image': 'https://via.placeholder.com/150'},
    ];

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
              children: friends.map((friend) => 
                _buildFriend(friend['name']!, friend['role']!, friend['image']!)
              ).toList(),
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
          _buildSettingOption('Logout', Icons.logout, () => _showLogoutDialog(context)),
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
            backgroundColor: lightPurple,
            backgroundImage: NetworkImage(imageUrl),
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