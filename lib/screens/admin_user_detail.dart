import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final String userId;

  const AdminUserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  _AdminUserDetailScreenState createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  List<dynamic> _userBookings = [];
  String? _errorMessage;
  late TabController _tabController;
  final String baseUrl = 'http://192.168.254.140:3000/api';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('adminToken');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userData = data['user'] ?? {};
          _userBookings = data['bookings'] ?? [];
          _isLoading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['msg'] ?? 'Failed to load user data';
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

  Future<void> _toggleUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('adminToken');

      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/${widget.userId}/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'isActive': !(_userData['isActive'] == true),
        }),
      );

      if (response.statusCode == 200) {
        _fetchUserData(); // Refresh the data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

  Future<void> _deleteUser() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
          'Are you sure you want to delete this user? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('adminToken');

        final response = await http.delete(
          Uri.parse('$baseUrl/admin/users/${widget.userId}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          // Pop back to users list
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['msg'] ?? 'Failed to delete user'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteUser,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Bookings'),
            Tab(text: 'Activity'),
          ],
        ),
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
                        onPressed: _fetchUserData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildBookingsTab(),
                    _buildActivityTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchUserData,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileTab() {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final createdAt = _userData['createdAt'] != null 
        ? dateFormatter.format(DateTime.parse(_userData['createdAt']))
        : 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      (_userData['name'] as String?)?.isNotEmpty == true
                          ? (_userData['name'] as String).substring(0, 1).toUpperCase()
                          : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData['name'] ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _userData['email'] ?? 'No email',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _userData['isActive'] == true
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _userData['isActive'] == true ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: _userData['isActive'] == true ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Joined: $createdAt',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Toggle status button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleUserStatus,
              icon: Icon(
                _userData['isActive'] == true ? Icons.block : Icons.check_circle,
              ),
              label: Text(
                _userData['isActive'] == true ? 'Deactivate User' : 'Activate User',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _userData['isActive'] == true ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // User details section
          _sectionHeader('User Details'),
          const SizedBox(height: 8),
          
          _detailItem('Name', _userData['name'] ?? 'Not provided'),
          _detailItem('Email', _userData['email'] ?? 'Not provided'),
          _detailItem('Phone', _userData['phone'] ?? 'Not provided'),
          _detailItem('Created At', createdAt),
          _detailItem('Last Login', _userData['lastLogin'] != null 
              ? dateFormatter.format(DateTime.parse(_userData['lastLogin']))
              : 'Never'),
          
          const SizedBox(height: 24),
          
          // User stats section
          _sectionHeader('User Statistics'),
          const SizedBox(height: 8),
          
          Row(
            children: [
              _statCard('Total Bookings', _userBookings.length.toString()),
              const SizedBox(width: 16),
              _statCard('Completed', _userBookings.where((b) => b['status'] == 'completed').length.toString()),
              const SizedBox(width: 16),
              _statCard('Pending', _userBookings.where((b) => b['status'] == 'pending').length.toString()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Admin notes section
          _sectionHeader('Admin Notes'),
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter notes about this user...',
                border: InputBorder.none,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Save notes functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notes saved')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Notes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    return _userBookings.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No bookings found for this user',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _userBookings.length,
            itemBuilder: (context, index) {
              final booking = _userBookings[index];
              final dateFormatter = DateFormat('MMM dd, yyyy');
              final bookingDate = booking['date'] != null 
                  ? dateFormatter.format(DateTime.parse(booking['date']))
                  : 'Unknown date';
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(booking['status']).withOpacity(0.2),
                    child: Icon(
                      _getStatusIcon(booking['status']),
                      color: _getStatusColor(booking['status']),
                    ),
                  ),
                  title: Text(
                    booking['eventName'] ?? 'Unknown Event',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    bookingDate,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(booking['status']),
                      style: TextStyle(
                        color: _getStatusColor(booking['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bookingDetailItem('Vendor', booking['vendorName'] ?? 'Unknown Vendor'),
                          _bookingDetailItem('Location', booking['location'] ?? 'No location'),
                          _bookingDetailItem('Amount', '₹${booking['amount']?.toString() ?? '0'}'),
                          _bookingDetailItem('Payment Status', _getPaymentStatusText(booking['paymentStatus'])),
                          _bookingDetailItem('Created At', booking['createdAt'] != null 
                              ? dateFormatter.format(DateTime.parse(booking['createdAt']))
                              : 'Unknown'),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  // View details action
                                },
                                icon: const Icon(Icons.visibility),
                                label: const Text('View Details'),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // View payment action
                                },
                                icon: const Icon(Icons.payment),
                                label: const Text('View Payment'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildActivityTab() {
    return Center(
      child: Text(
        'Activity log will be available soon',
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_top;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.event;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String _getPaymentStatusText(String? status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }
}

