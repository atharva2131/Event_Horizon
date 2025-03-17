import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';

class AdminVendorsScreen extends StatefulWidget {
  const AdminVendorsScreen({super.key});

  @override
  _AdminVendorsScreenState createState() => _AdminVendorsScreenState();
}

class _AdminVendorsScreenState extends State<AdminVendorsScreen> {
  bool _isLoading = false;
  List<dynamic> _vendors = [];
  List<dynamic> _pendingVendors = [];
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadVendors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vendors = await ApiService.fetchVendors();
      final pendingVendors = await ApiService.fetchPendingVendors();
      
      if (mounted) {
        setState(() {
          _vendors = vendors;
          _pendingVendors = pendingVendors;
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

  void _toggleVendorStatus(String vendorId, bool isActive) async {
    try {
      await ApiService.toggleVendorStatus(vendorId, isActive);
      
      if (mounted) {
        setState(() {
          for (var i = 0; i < _vendors.length; i++) {
            if (_vendors[i]['_id'] == vendorId) {
              _vendors[i]['isActive'] = !isActive;
              break;
            }
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendor status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update vendor status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _approveVendor(String vendorId) async {
    try {
      await ApiService.approveVendor(vendorId);
      
      // Find the vendor in pending list
      final vendorIndex = _pendingVendors.indexWhere((v) => v['_id'] == vendorId);
      if (vendorIndex != -1) {
        final vendor = _pendingVendors[vendorIndex];
        
        if (mounted) {
          // Add to approved vendors
          setState(() {
            _vendors.add({
              ...vendor,
              'isActive': true,
              'eventsHosted': 0,
              'rating': 0.0
            });
            
            // Remove from pending
            _pendingVendors.removeAt(vendorIndex);
          });
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve vendor: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectVendor(String vendorId) async {
    try {
      await ApiService.rejectVendor(vendorId);
      
      if (mounted) {
        setState(() {
          _pendingVendors.removeWhere((v) => v['_id'] == vendorId);
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendor rejected successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject vendor: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredVendors {
    if (_searchQuery.isEmpty) {
      return _vendors;
    }
    return _vendors.where((vendor) {
      final name = vendor['name']?.toString().toLowerCase() ?? '';
      final email = vendor['email']?.toString().toLowerCase() ?? '';
      final phone = vendor['phone']?.toString() ?? '';
      final business = vendor['businessName']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) || 
             email.contains(_searchQuery.toLowerCase()) ||
             phone.contains(_searchQuery) ||
             business.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Vendor Management',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(
                text: 'All Vendors (${_vendors.length})',
              ),
              Tab(
                text: 'Pending Approval (${_pendingVendors.length})',
              ),
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
                          onPressed: _loadVendors,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    children: [
                      _buildAllVendorsTab(),
                      _buildPendingVendorsTab(),
                    ],
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: _loadVendors,
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAllVendorsTab() {
    return Column(
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
              hintText: 'Search vendors by name, email, phone or business',
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
              _statCard('Total Vendors', _vendors.length.toString(), Colors.deepPurple),
              const SizedBox(width: 8),
              _statCard(
                'Active Vendors', 
                _vendors.where((vendor) => vendor['isActive'] == true).length.toString(),
                Colors.green,
              ),
              const SizedBox(width: 8),
              _statCard(
                'Inactive Vendors', 
                _vendors.where((vendor) => vendor['isActive'] == false).length.toString(),
                Colors.red,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Vendors list
        Expanded(
          child: _filteredVendors.isEmpty
              ? Center(
                  child: Text(
                    'No vendors found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredVendors.length,
                  itemBuilder: (context, index) {
                    final vendor = _filteredVendors[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: vendor['isActive'] == true
                              ? Colors.deepPurple.shade100
                              : Colors.grey.shade300,
                          child: Text(
                            (vendor['name'] as String?)?.isNotEmpty == true
                                ? (vendor['name'] as String).substring(0, 1).toUpperCase()
                                : 'V',
                            style: TextStyle(
                              color: vendor['isActive'] == true
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
                                vendor['businessName'] ?? 'Unknown Business',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: vendor['isActive'] == true
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                vendor['isActive'] == true ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: vendor['isActive'] == true ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Owner: ${vendor['name'] ?? 'Unknown'}'),
                            Text('Email: ${vendor['email'] ?? 'No email'}'),
                            Text('Phone: ${vendor['phone'] ?? 'Not provided'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: vendor['isActive'] == true,
                              activeColor: Colors.deepPurple,
                              onChanged: (value) {
                                _toggleVendorStatus(vendor['_id'], vendor['isActive'] == true);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.navigate_next),
                              onPressed: () {
                                // Navigate to vendor detail screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vendor detail view would open here'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          // Navigate to vendor detail screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vendor detail view would open here'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPendingVendorsTab() {
    return _pendingVendors.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending vendor approvals',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _pendingVendors.length,
            itemBuilder: (context, index) {
              final vendor = _pendingVendors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      (vendor['name'] as String?)?.isNotEmpty == true
                          ? (vendor['name'] as String).substring(0, 1).toUpperCase()
                          : 'V',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    vendor['businessName'] ?? 'Unknown Business',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Owner: ${vendor['name'] ?? 'Unknown'}'),
                      Text('Applied on: ${_formatDate(vendor['createdAt'])}'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Pending',
                      style: TextStyle(
                        color: Colors.orange,
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
                          _vendorDetailItem('Email', vendor['email'] ?? 'No email'),
                          _vendorDetailItem('Phone', vendor['phone'] ?? 'Not provided'),
                          _vendorDetailItem('Business Type', vendor['businessType'] ?? 'Not specified'),
                          _vendorDetailItem('Address', vendor['address'] ?? 'Not provided'),
                          _vendorDetailItem('Description', vendor['description'] ?? 'No description'),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _approveVendor(vendor['_id']),
                                icon: const Icon(Icons.check),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _rejectVendor(vendor['_id']),
                                icon: const Icon(Icons.close),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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

  Widget _vendorDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}