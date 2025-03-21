import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdminVendorDetailScreen extends StatefulWidget {
  final String vendorId;

  const AdminVendorDetailScreen({
    super.key,
    required this.vendorId,
  });

  @override
  _AdminVendorDetailScreenState createState() => _AdminVendorDetailScreenState();
}

class _AdminVendorDetailScreenState extends State<AdminVendorDetailScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic> _vendorData = {};
  List<dynamic> _vendorBookings = [];
  List<dynamic> _vendorServices = [];
  String? _errorMessage;
  late TabController _tabController;
  final String baseUrl = 'http://192.168.254.140:3000/api';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchVendorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendorData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('adminToken');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/vendors/${widget.vendorId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _vendorData = data['vendor'] ?? {};
          _vendorBookings = data['bookings'] ?? [];
          _vendorServices = data['services'] ?? [];
          _isLoading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['msg'] ?? 'Failed to load vendor data';
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

  Future<void> _toggleVendorStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('adminToken');

      final response = await http.patch(
        Uri.parse('$baseUrl/admin/vendors/${widget.vendorId}/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'isActive': !(_vendorData['isActive'] == true),
        }),
      );

      if (response.statusCode == 200) {
        _fetchVendorData(); // Refresh the data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendor status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['msg'] ?? 'Failed to update vendor status'),
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

  Future<void> _deleteVendor() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
          'Are you sure you want to delete this vendor? This action cannot be undone.'
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
          Uri.parse('$baseUrl/admin/vendors/${widget.vendorId}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          // Pop back to vendors list
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['msg'] ?? 'Failed to delete vendor'),
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
          'Vendor Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteVendor,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Services'),
            Tab(text: 'Bookings'),
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
                        onPressed: _fetchVendorData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildServicesTab(),
                    _buildBookingsTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchVendorData,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileTab() {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final createdAt = _vendorData['createdAt'] != null 
        ? dateFormatter.format(DateTime.parse(_vendorData['createdAt']))
        : 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vendor header card
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
                      (_vendorData['businessName'] as String?)?.isNotEmpty == true
                          ? (_vendorData['businessName'] as String).substring(0, 1).toUpperCase()
                          : 'V',
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
                          _vendorData['businessName'] ?? 'Unknown Business',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Owner: ${_vendorData['name'] ?? 'Unknown'}',
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
                                color: _vendorData['isActive'] == true
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _vendorData['isActive'] == true ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: _vendorData['isActive'] == true ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Since: $createdAt',
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
              onPressed: _toggleVendorStatus,
              icon: Icon(
                _vendorData['isActive'] == true ? Icons.block : Icons.check_circle,
              ),
              label: Text(
                _vendorData['isActive'] == true ? 'Deactivate Vendor' : 'Activate Vendor',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _vendorData['isActive'] == true ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Vendor details section
          _sectionHeader('Vendor Details'),
          const SizedBox(height: 8),
          
          _detailItem('Business Name', _vendorData['businessName'] ?? 'Not provided'),
          _detailItem('Owner Name', _vendorData['name'] ?? 'Not provided'),
          _detailItem('Email', _vendorData['email'] ?? 'Not provided'),
          _detailItem('Phone', _vendorData['phone'] ?? 'Not provided'),
          _detailItem('Business Type', _vendorData['businessType'] ?? 'Not specified'),
          _detailItem('Address', _vendorData['address'] ?? 'Not provided'),
          _detailItem('Joined On', createdAt),
          
          const SizedBox(height: 24),
          
          // Vendor stats section
          _sectionHeader('Vendor Statistics'),
          const SizedBox(height: 8),
          
          Row(
            children: [
              _statCard('Total Services', _vendorServices.length.toString()),
              const SizedBox(width: 16),
              _statCard('Total Bookings', _vendorBookings.length.toString()),
              const SizedBox(width: 16),
              _statCard('Completed', _vendorBookings.where((b) => b['status'] == 'completed').length.toString()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Vendor description
          _sectionHeader('Business Description'),
          const SizedBox(height: 8),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _vendorData['description'] ?? 'No description provided.',
              style: GoogleFonts.poppins(),
            ),
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
                hintText: 'Enter notes about this vendor...',
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

  Widget _buildServicesTab() {
    return _vendorServices.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_mall_directory,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No services found for this vendor',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _vendorServices.length,
            itemBuilder: (context, index) {
              final service = _vendorServices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    service['name'] ?? 'Unknown Service',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '₹${service['price']?.toString() ?? '0'}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: service['isActive'] == true
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service['isActive'] == true ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: service['isActive'] == true ? Colors.green : Colors.red,
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
                          Text(
                            'Description:',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            service['description'] ?? 'No description provided.',
                            style: GoogleFonts.poppins(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Features:',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (service['features'] != null && service['features'] is List)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (service['features'] as List).map<Widget>((feature) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(feature.toString()),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            Text('No features listed.'),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  // Toggle service status action
                                },
                                icon: Icon(
                                  service['isActive'] == true ? Icons.block : Icons.check_circle,
                                  color: service['isActive'] == true ? Colors.red : Colors.green,
                                ),
                                label: Text(
                                  service['isActive'] == true ? 'Deactivate' : 'Activate',
                                  style: TextStyle(
                                    color: service['isActive'] == true ? Colors.red : Colors.green,
                                  ),
                                ),
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

  Widget _buildBookingsTab() {
    return _vendorBookings.isEmpty
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
                  'No bookings found for this vendor',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _vendorBookings.length,
            itemBuilder: (context, index) {
              final booking = _vendorBookings[index];
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
                    'User: ${booking['userName'] ?? 'Unknown User'}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
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
                      const SizedBox(height: 4),
                      Text(
                        bookingDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bookingDetailItem('Event Name', booking['eventName'] ?? 'Unknown Event'),
                          _bookingDetailItem('User', booking['userName'] ?? 'Unknown User'),
                          _bookingDetailItem('Service', booking['serviceName'] ?? 'Unknown Service'),
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
            width: 120,
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

