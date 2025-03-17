import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminBookingDetailScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;
  final Function(String, String) onStatusUpdate;

  const AdminBookingDetailScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
    required this.onStatusUpdate,
  });

  @override
  _AdminBookingDetailScreenState createState() => _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  late Map<String, dynamic> _booking;

  @override
  void initState() {
    super.initState();
    // Use the provided booking data
    _booking = widget.bookingData;
    
    // Add additional mock data that might not be in the list view
    _booking.addAll({
      'userEmail': 'user@example.com',
      'userPhone': '+91 9876543210',
      'vendorEmail': 'vendor@example.com',
      'vendorPhone': '+91 9876543211',
      'service': 'Full Event Management',
      'paymentStatus': _booking['status'] == 'cancelled' ? 'refunded' : 'paid',
      'paymentMethod': 'Credit Card',
      'transactionId': 'TXN${widget.bookingId}12345',
      'notes': _booking['status'] == 'pending' 
          ? 'Customer requested special arrangements for seating.'
          : '',
    });
  }

  void _updateBookingStatus(String status) {
    setState(() {
      _booking['status'] = status;
    });
    
    // Call the parent's update function
    widget.onStatusUpdate(widget.bookingId, status);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking status updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getStatusColor(_booking['status']).withOpacity(0.2),
                          child: Icon(
                            _getStatusIcon(_booking['status']),
                            color: _getStatusColor(_booking['status']),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _getStatusText(_booking['status']),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(_booking['status']),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          onSelected: _updateBookingStatus,
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'pending',
                              child: Text('Mark as Pending'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'confirmed',
                              child: Text('Mark as Confirmed'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'completed',
                              child: Text('Mark as Completed'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'cancelled',
                              child: Text('Mark as Cancelled'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Update',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,

                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Event details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _detailItem('Event Name', _booking['eventName'] ?? 'Unknown'),
                    _detailItem('Event Type', _booking['eventType'] ?? 'Unknown'),
                    _detailItem(
                      'Date',
                      _booking['date'] != null
                          ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(_booking['date']))
                          : 'Unknown',
                    ),
                    _detailItem('Time', _booking['time'] ?? 'Unknown'),
                    _detailItem('Location', _booking['location'] ?? 'Unknown'),
                    _detailItem('Guests', _booking['guests']?.toString() ?? 'Unknown'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // User details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _detailItem('Name', _booking['userName'] ?? 'Unknown'),
                    _detailItem('Email', _booking['userEmail'] ?? 'Unknown'),
                    _detailItem('Phone', _booking['userPhone'] ?? 'Unknown'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Vendor details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _detailItem('Name', _booking['vendorName'] ?? 'Unknown'),
                    _detailItem('Email', _booking['vendorEmail'] ?? 'Unknown'),
                    _detailItem('Phone', _booking['vendorPhone'] ?? 'Unknown'),
                    _detailItem('Service', _booking['service'] ?? 'Unknown'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _detailItem(
                      'Amount',
                      '₹${_booking['amount']?.toString() ?? '0'}',
                      valueStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    _detailItem('Payment Status', _booking['paymentStatus'] ?? 'Unknown'),
                    _detailItem('Payment Method', _booking['paymentMethod'] ?? 'Unknown'),
                    _detailItem('Transaction ID', _booking['transactionId'] ?? 'N/A'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes
            if (_booking['notes'] != null && _booking['notes'].toString().isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Text(_booking['notes']),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contacting user...'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Contact User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contacting vendor...'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.business),
                  label: const Text('Contact Vendor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value, {TextStyle? valueStyle}) {
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
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(),
            ),
          ),
        ],
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

