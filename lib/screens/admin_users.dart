import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'admin_user_detail.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final String baseUrl = 'http://localhost:3000/api/auth/users';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('adminToken');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _users = data['users'] ?? [];
          _isLoading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['msg'] ?? 'Failed to load users';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUserStatus(String userId, bool isActive) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('adminToken');

      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'isActive': !isActive,
        }),
      );

      if (response.statusCode == 200) {
        _fetchUsers(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['msg'] ?? 'Failed to update user status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    return _users.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final phone = user['phone']?.toString() ?? '';
      return name.contains(_searchQuery.toLowerCase()) || 
             email.contains(_searchQuery.toLowerCase()) ||
             phone.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUsers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          hintText: 'Search users by name, email or phone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    
                    // Stats bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _statCard('Total Users', _users.length.toString(), Colors.deepPurple),
                          const SizedBox(width: 8),
                          _statCard(
                            'Active Users', 
                            _users.where((user) => user['isActive'] == true).length.toString(),
                            Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _statCard(
                            'Inactive Users', 
                            _users.where((user) => user['isActive'] == false).length.toString(),
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Users list
                    Expanded(
                      child: _filteredUsers.isEmpty
                          ? Center(
                              child: Text(
                                'No users found',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: user['isActive'] == true
                                          ? Colors.deepPurple.shade100
                                          : Colors.grey.shade300,
                                      child: Text(
                                        (user['name'] as String?)?.isNotEmpty == true
                                            ? (user['name'] as String).substring(0, 1).toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          color: user['isActive'] == true
                                              ? Colors.deepPurple
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      user['name'] ?? 'Unknown',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user['email'] ?? 'No email'),
                                        Text('Phone: ${user['phone'] ?? 'Not provided'}'),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: user['isActive'] == true,
                                          activeColor: Colors.deepPurple,
                                          onChanged: (value) {
                                            _toggleUserStatus(user['_id'], user['isActive'] == true);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.navigate_next),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AdminUserDetailScreen(
                                                  userId: user['_id'],
                                                ),
                                              ),
                                            ).then((_) => _fetchUsers());
                                          },
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminUserDetailScreen(
                                            userId: user['_id'],
                                          ),
                                        ),
                                      ).then((_) => _fetchUsers());
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchUsers,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

