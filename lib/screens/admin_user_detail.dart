import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';


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
  final TextEditingController _notesController = TextEditingController();
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch user data using API service
      final userData = await ApiService.fetchUserById(widget.userId);
      
      // Fetch user bookings if needed
      List<dynamic> bookings = [];
      try {
        bookings = await ApiService.fetchUserBookings(widget.userId);
      } catch (e) {
        // Silently handle booking fetch errors
        debugPrint('Error fetching bookings: $e');
      }
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _userBookings = bookings;
          _notesController.text = userData['adminNotes'] ?? '';
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

  Future<void> _toggleUserStatus() async {
    try {
      await ApiService.toggleUserStatus(widget.userId, _userData['isActive'] == true);
      
      if (mounted) {
        setState(() {
          _userData['isActive'] = !(_userData['isActive'] == true);
        });
        
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

  Future<void> _changeUserRole() async {
    final currentRole = _userData['role'] ?? 'user';
    
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
      await ApiService.changeUserRole(widget.userId, newRole);
      
      // Update local state
      if (mounted) {
        setState(() {
          _userData['role'] = newRole;
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

  Future<void> _saveNotes() async {
    if (_isSavingNotes) return;
    
    setState(() {
      _isSavingNotes = true;
    });
    
    try {
      await ApiService.updateUserNotes(widget.userId, _notesController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save notes: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingNotes = false;
        });
      }
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
        await ApiService.deleteUser(widget.userId);
        
        if (!mounted) return;
        
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete user: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
    final userRole = _userData['role'] ?? 'user';

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
                            // Status badge
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
                            // Role badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getRoleBadgeColor(userRole).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                userRole.toUpperCase(),
                                style: TextStyle(
                                  color: _getRoleBadgeColor(userRole),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Joined: $createdAt',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              // Toggle status button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleUserStatus,
                  icon: Icon(
                    _userData['isActive'] == true ? Icons.block : Icons.check_circle,
                  ),
                  label: Text(
                    _userData['isActive'] == true ? 'Deactivate' : 'Activate',
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
              const SizedBox(width: 12),
              // Change role button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _changeUserRole,
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Change Role'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // User details section
          _sectionHeader('User Details'),
          const SizedBox(height: 8),
          
          _detailItem('Name', _userData['name'] ?? 'Not provided'),
          _detailItem('Email', _userData['email'] ?? 'Not provided'),
          _detailItem('Phone', _userData['phone'] ?? 'Not provided'),
          _detailItem('Role', userRole.toUpperCase()),
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
              controller: _notesController,
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
              onPressed: _isSavingNotes ? null : _saveNotes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSavingNotes 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Notes'),
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

