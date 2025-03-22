import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_user_detail.dart';
import 'api_service.dart';

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
      // Use the API service to fetch users
      final users = await ApiService.fetchUsers();
      
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleUserStatus(String userId, bool isActive) async {
    try {
      await ApiService.toggleUserStatus(userId, isActive);
      
      if (mounted) {
        setState(() {
          for (var i = 0; i < _users.length; i++) {
            if (_users[i]['_id'] == userId) {
              _users[i]['isActive'] = !isActive;
              break;
            }
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeUserRole(String userId, String currentRole) async {
    // Show dialog to select new role
    final String? newRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change User Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current role: $currentRole'),
              const SizedBox(height: 16),
              const Text('Select new role:'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'user'),
              child: const Text('User'),
              style: TextButton.styleFrom(
                foregroundColor: currentRole == 'user' ? Colors.grey : Colors.deepPurple,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'vendor'),
              child: const Text('Vendor'),
              style: TextButton.styleFrom(
                foregroundColor: currentRole == 'vendor' ? Colors.grey : Colors.deepPurple,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'admin'),
              child: const Text('Admin'),
              style: TextButton.styleFrom(
                foregroundColor: currentRole == 'admin' ? Colors.grey : Colors.deepPurple,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    // If no role selected or same role selected, do nothing
    if (newRole == null || newRole == currentRole) return;

    try {
      // Call API to change role
      await ApiService.changeUserRole(userId, newRole);
      
      // Update local state
      if (mounted) {
        setState(() {
          for (var i = 0; i < _users.length; i++) {
            if (_users[i]['_id'] == userId) {
              _users[i]['role'] = newRole;
              break;
            }
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User role changed to $newRole successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change user role: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      final role = user['role']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) || 
             email.contains(_searchQuery.toLowerCase()) ||
             phone.contains(_searchQuery) ||
             role.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Get role badge color
  Color _getRoleBadgeColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'vendor':
        return Colors.blue;
      case 'user':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
                          hintText: 'Search users by name, email, phone or role',
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
                    
                    // Role stats
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          _statCard(
                            'Admins', 
                            _users.where((user) => user['role'] == 'admin').length.toString(),
                            Colors.purple,
                          ),
                          const SizedBox(width: 8),
                          _statCard(
                            'Vendors', 
                            _users.where((user) => user['role'] == 'vendor').length.toString(),
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _statCard(
                            'Regular Users', 
                            _users.where((user) => user['role'] == 'user').length.toString(),
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                    
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
                                final userRole = user['role'] ?? 'user';
                                
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
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user['name'] ?? 'Unknown',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getRoleBadgeColor(userRole).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            userRole.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getRoleBadgeColor(userRole),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                        // Role change button
                                        IconButton(
                                          icon: const Icon(Icons.manage_accounts),
                                          tooltip: 'Change Role',
                                          onPressed: () {
                                            _changeUserRole(user['_id'], userRole);
                                          },
                                        ),
                                        // Status toggle
                                        Switch(
                                          value: user['isActive'] == true,
                                          activeColor: Colors.deepPurple,
                                          onChanged: (value) {
                                            _toggleUserStatus(user['_id'], user['isActive'] == true);
                                          },
                                        ),
                                        // Details button
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

