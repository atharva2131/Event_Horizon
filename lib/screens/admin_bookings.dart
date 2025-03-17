import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'admin_booking_detail.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  _AdminBookingsScreenState createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _bookings = [];
  String _searchQuery = '';
  String _filterStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load mock data instead of API call
    _loadMockData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Simulate loading
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _bookings = [
          {
            '_id': '1',
            'eventName': 'Wedding Ceremony',
            'status': 'confirmed',
            'date': '2025-04-15',
            'userName': 'John Smith',
            'vendorName': 'Elegant Events',
            'location': 'Grand Plaza Hotel',
            'amount': 25000,
            'eventType': 'Wedding',
            'time': '6:00 PM',
            'guests': 150,
          },
          {
            '_id': '2',
            'eventName': 'Corporate Conference',
            'status': 'pending',
            'date': '2025-05-20',
            'userName': 'Sarah Johnson',
            'vendorName': 'Business Solutions',
            'location': 'Tech Convention Center',
            'amount': 35000,
            'eventType': 'Corporate',
            'time': '9:00 AM',
            'guests': 200,
          },
          {
            '_id': '3',
            'eventName': 'Birthday Party',
            'status': 'completed',
            'date': '2025-03-10',
            'userName': 'Mike Davis',
            'vendorName': 'Party Planners',
            'location': 'Sunset Restaurant',
            'amount': 15000,
            'eventType': 'Birthday',
            'time': '7:30 PM',
            'guests': 50,
          },
          {
            '_id': '4',
            'eventName': 'Product Launch',
            'status': 'cancelled',
            'date': '2025-04-05',
            'userName': 'Tech Innovations Inc',
            'vendorName': 'Launch Masters',
            'location': 'Digital Dome',
            'amount': 45000,
            'eventType': 'Corporate',
            'time': '10:00 AM',
            'guests': 300,
          },
          {
            '_id': '5',
            'eventName': 'Anniversary Celebration',
            'status': 'confirmed',
            'date': '2025-06-12',
            'userName': 'Robert & Lisa Wilson',
            'vendorName': 'Milestone Events',
            'location': 'Harmony Gardens',
            'amount': 20000,
            'eventType': 'Anniversary',
            'time': '5:00 PM',
            'guests': 75,
          },
        ];
        _isLoading = false;
      });
    });
  }

  void _updateBookingStatus(String bookingId, String status) {
    // Update booking status in mock data
    setState(() {
      final index = _bookings.indexWhere((booking) => booking['_id'] == bookingId);
      if (index != -1) {
        _bookings[index]['status'] = status;
      }
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking status updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredBookings {
    return _bookings.where((booking) {
      // First apply status filter
      if (_filterStatus != 'all' && booking['status'] != _filterStatus) {
        return false;
      }
      
      // Then apply search query
      if (_searchQuery.isEmpty) {
        return true;
      }
      
      final eventName = booking['eventName']?.toString().toLowerCase() ?? '';
      final userName = booking['userName']?.toString().toLowerCase() ?? '';
      final vendorName = booking['vendorName']?.toString().toLowerCase() ?? '';
      final location = booking['location']?.toString().toLowerCase() ?? '';
      
      return eventName.contains(_searchQuery.toLowerCase()) ||
             userName.contains(_searchQuery.toLowerCase()) ||
             vendorName.contains(_searchQuery.toLowerCase()) ||
             location.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking Management',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      hintText: 'Search by event, user, vendor or location',
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
                
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _filterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _filterChip('Pending', 'pending'),
                      const SizedBox(width: 8),
                      _filterChip('Confirmed', 'confirmed'),
                      const SizedBox(width: 8),
                      _filterChip('Completed', 'completed'),
                      const SizedBox(width: 8),
                      _filterChip('Cancelled', 'cancelled'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _statCard('Total', _bookings.length.toString(), Colors.deepPurple),
                      const SizedBox(width: 8),
                      _statCard(
                        'Pending', 
                        _bookings.where((b) => b['status'] == 'pending').length.toString(), 
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _statCard(
                        'Completed', 
                        _bookings.where((b) => b['status'] == 'completed').length.toString(), 
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bookings list
                Expanded(
                  child: _filteredBookings.isEmpty
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
                                'No bookings found',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = _filteredBookings[index];
                            final dateFormatter = DateFormat('MMM dd, yyyy');
                            final bookingDate = booking['date'] != null
                                ? dateFormatter.format(DateTime.parse(booking['date']))
                                : 'Unknown date';

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(booking['status']).withOpacity(0.2),
                                  child: Icon(
                                    _getStatusIcon(booking['status']),
                                    color: _getStatusColor(booking['status']),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        booking['eventName'] ?? 'Unknown Event',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(booking['status']).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusText(booking['status']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getStatusColor(booking['status']),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date: $bookingDate'),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text('User: ${booking['userName'] ?? 'Unknown'}'),
                                        ),
                                        Text(
                                          '₹${booking['amount']?.toString() ?? '0'}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('Vendor: ${booking['vendorName'] ?? 'Unknown'}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.navigate_next),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminBookingDetailScreen(
                                          bookingId: booking['_id'],
                                          bookingData: booking,
                                          onStatusUpdate: _updateBookingStatus,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                isThreeLine: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminBookingDetailScreen(
                                        bookingId: booking['_id'],
                                        bookingData: booking,
                                        onStatusUpdate: _updateBookingStatus,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMockData,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? value : 'all';
        });
      },
      selectedColor: Colors.deepPurple.shade100,
      checkmarkColor: Colors.deepPurple,
      labelStyle: TextStyle(
        color: isSelected ? Colors.deepPurple : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
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
      case 'confirmed':
        return Icons.event_available;
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
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}

