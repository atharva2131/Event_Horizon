import 'package:flutter/material.dart';
import 'package:eventhorizon/screens/Vendor_AccountSettingsScreen.dart';
import 'package:eventhorizon/screens/vendor_notifications_screen.dart';
import 'package:eventhorizon/screens/vendor_payment_methods_screen.dart';
import 'package:eventhorizon/screens/vendor_help_support_screen.dart';
import 'package:eventhorizon/screens/vendor_privacy_terms_screen.dart';
import 'package:eventhorizon/screens/SignInPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VendorProfileScreen extends StatefulWidget {
  final int vendorIndex;

  const VendorProfileScreen({super.key, required this.vendorIndex});

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  // Define our theme colors
  final Color primaryColor = const Color(0xFF4A148C); // Deep Purple 900
  final Color accentColor = const Color(0xFF7C43BD); // Lighter purple
  final Color backgroundColor = Colors.white;
  final Color cardColor = const Color(0xFFF5F0FF); // Very light purple

  Map<String, dynamic> vendorProfile = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVendorProfile();
  }

  Future<void> _loadVendorProfile() async {
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
      
      // Use the correct API URL
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
          vendorProfile = responseData['user'] ?? {};
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SignInPage(isUser: false,)),
      (route) => false,
    );
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
          vendorProfile = responseData['user'] ?? {};
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
        MaterialPageRoute(builder: (context) => SignInPage(isUser: false)),
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
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountSettingsScreen(
                    name: vendorProfile['name'] ?? "",
                    email: vendorProfile['email'] ?? "",
                    profilePicture: vendorProfile['profileImage'] ?? "",
                  ),
                ),
              );
              if (updatedData != null) {
                _updateProfile(updatedData['name'], updatedData['email'],
                    updatedData['profilePicture']);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryColor))
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
                          onPressed: _loadVendorProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 20),
                      _buildStatistics(),
                      const SizedBox(height: 24),
                      _buildActiveCollaborations(),
                      const SizedBox(height: 24),
                      _buildSettingsAndPreferences(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Container(
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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(vendorProfile['profileImage'] ?? "https://via.placeholder.com/150"),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            vendorProfile['name'] ?? "Vendor Name",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            vendorProfile['email'] ?? "vendor@example.com",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          if (vendorProfile['phone'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                vendorProfile['phone'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${vendorProfile['rating'] ?? "0.0"}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${vendorProfile['reviews_count'] ?? "0"} reviews)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountSettingsScreen(
                    name: vendorProfile['name'] ?? "",
                    email: vendorProfile['email'] ?? "",
                    profilePicture: vendorProfile['profileImage'] ?? "",
                  ),
                ),
              );
              if (updatedData != null) {
                _updateProfile(updatedData['name'], updatedData['email'],
                    updatedData['profilePicture']);
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatisticCard(
              vendorProfile['ongoing_orders']?.toString() ?? "0",
              'Ongoing Orders',
              Icons.assignment,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatisticCard(
              '\$${vendorProfile['total_earnings']?.toString() ?? "0"}',
              'Earnings',
              Icons.attach_money,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatisticCard(
              vendorProfile['rating']?.toString() ?? "0.0",
              'Rating',
              Icons.star,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCollaborations() {
    // This would ideally be fetched from the backend
    List<Map<String, String>> collaborators = [
      {'name': 'Sophia Lee', 'role': 'Florist', 'image': 'https://via.placeholder.com/150'},
      {'name': 'Daniel Smith', 'role': 'Lighting Expert', 'image': 'https://via.placeholder.com/150'},
      {'name': 'Emily Davis', 'role': 'Caterer', 'image': 'https://via.placeholder.com/150'},
      {'name': 'John Wilson', 'role': 'DJ', 'image': 'https://via.placeholder.com/150'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: collaborators.map((collaborator) => 
              _buildCollaborator(collaborator['name']!, collaborator['role']!, collaborator['image']!)
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsAndPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Settings & Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
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
                        name: vendorProfile['name'] ?? "",
                        email: vendorProfile['email'] ?? "",
                        profilePicture: vendorProfile['profileImage'] ?? "",
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
              _buildDivider(),
              _buildSettingOption(
                'Logout',
                Icons.logout,
                context,
                () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ],
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