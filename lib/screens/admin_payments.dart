import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  _AdminPaymentsScreenState createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _payments = [];
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
        _payments = [
          {
            'paymentId': 'PAY001',
            'bookingId': '1',
            'amount': 25000,
            'status': 'paid',
            'date': '2025-04-15',
            'userName': 'John Smith',
            'vendorName': 'Elegant Events',
            'eventName': 'Wedding Ceremony',
            'paymentMethod': 'Credit Card',
            'transactionId': 'TXN123456',
            'createdAt': '2025-04-10',
          },
          {
            'paymentId': 'PAY002',
            'bookingId': '2',
            'amount': 35000,
            'status': 'pending',
            'date': '2025-05-20',
            'userName': 'Sarah Johnson',
            'vendorName': 'Business Solutions',
            'eventName': 'Corporate Conference',
            'paymentMethod': 'Bank Transfer',
            'transactionId': '',
            'createdAt': '2025-05-15',
          },
          {
            'paymentId': 'PAY003',
            'bookingId': '3',
            'amount': 15000,
            'status': 'paid',
            'date': '2025-03-10',
            'userName': 'Mike Davis',
            'vendorName': 'Party Planners',
            'eventName': 'Birthday Party',
            'paymentMethod': 'UPI',
            'transactionId': 'UPI789012',
            'createdAt': '2025-03-05',
          },
          {
            'paymentId': 'PAY004',
            'bookingId': '4',
            'amount': 45000,
            'status': 'refunded',
            'date': '2025-04-05',
            'userName': 'Tech Innovations Inc',
            'vendorName': 'Launch Masters',
            'eventName': 'Product Launch',
            'paymentMethod': 'Credit Card',
            'transactionId': 'TXN345678',
            'createdAt': '2025-04-01',
          },
          {
            'paymentId': 'PAY005',
            'bookingId': '5',
            'amount': 20000,
            'status': 'paid',
            'date': '2025-06-12',
            'userName': 'Robert & Lisa Wilson',
            'vendorName': 'Milestone Events',
            'eventName': 'Anniversary Celebration',
            'paymentMethod': 'Debit Card',
            'transactionId': 'TXN901234',
            'createdAt': '2025-06-10',
          },
        ];
        _isLoading = false;
      });
    });
  }

  List<Map<String, dynamic>> get _filteredPayments {
    return _payments.where((payment) {
      // First apply status filter
      if (_filterStatus != 'all' && payment['status'] != _filterStatus) {
        return false;
      }
      
      // Then apply search query
      if (_searchQuery.isEmpty) {
        return true;
      }
      
      final bookingId = payment['bookingId']?.toString().toLowerCase() ?? '';
      final userName = payment['userName']?.toString().toLowerCase() ?? '';
      final vendorName = payment['vendorName']?.toString().toLowerCase() ?? '';
      final paymentId = payment['paymentId']?.toString().toLowerCase() ?? '';
      
      return bookingId.contains(_searchQuery.toLowerCase()) ||
             userName.contains(_searchQuery.toLowerCase()) ||
             vendorName.contains(_searchQuery.toLowerCase()) ||
             paymentId.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Management',
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
                      hintText: 'Search by user, vendor or payment ID',
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
                      _filterChip('Paid', 'paid'),
                      const SizedBox(width: 8),
                      _filterChip('Pending', 'pending'),
                      const SizedBox(width: 8),
                      _filterChip('Failed', 'failed'),
                      const SizedBox(width: 8),
                      _filterChip('Refunded', 'refunded'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _statCard('Total', _payments.length.toString(), Colors.deepPurple),
                      const SizedBox(width: 8),
                      _statCard(
                        'Paid', 
                        _payments.where((p) => p['status'] == 'paid').length.toString(), 
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _statCard(
                        'Pending', 
                        _payments.where((p) => p['status'] == 'pending').length.toString(), 
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Payments list
                Expanded(
                  child: _filteredPayments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No payments found',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredPayments.length,
                          itemBuilder: (context, index) {
                            final payment = _filteredPayments[index];
                            final dateFormatter = DateFormat('MMM dd, yyyy');
                            final paymentDate = payment['date'] != null
                                ? dateFormatter.format(DateTime.parse(payment['date']))
                                : 'Unknown date';

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(payment['status']).withOpacity(0.2),
                                  child: Icon(
                                    _getStatusIcon(payment['status']),
                                    color: _getStatusColor(payment['status']),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '₹${payment['amount']?.toString() ?? '0'}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(payment['status']).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusText(payment['status']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getStatusColor(payment['status']),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date: $paymentDate'),
                                    Text('User: ${payment['userName'] ?? 'Unknown'}'),
                                    Text('Vendor: ${payment['vendorName'] ?? 'Unknown'}'),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _paymentDetailItem('Payment ID', payment['paymentId'] ?? 'Unknown'),
                                        _paymentDetailItem('Booking ID', payment['bookingId'] ?? 'Unknown'),
                                        _paymentDetailItem('Event', payment['eventName'] ?? 'Unknown Event'),
                                        _paymentDetailItem('Payment Method', payment['paymentMethod'] ?? 'Unknown'),
                                        _paymentDetailItem('Transaction ID', payment['transactionId'] ?? 'N/A'),
                                        _paymentDetailItem('Created At', payment['createdAt'] != null 
                                            ? dateFormatter.format(DateTime.parse(payment['createdAt']))
                                            : 'Unknown'),
                                        
                                        const SizedBox(height: 16),
                                        
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            if (payment['status'] == 'paid')
                                              TextButton.icon(
                                                onPressed: () {
                                                  // Refund action
                                                  _showRefundDialog(payment);
                                                },
                                                icon: const Icon(Icons.money_off, color: Colors.red),
                                                label: const Text('Refund', style: TextStyle(color: Colors.red)),
                                              ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Viewing receipt...'),
                                                    backgroundColor: Colors.blue,
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.receipt),
                                              label: const Text('View Receipt'),
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

  Future<void> _showRefundDialog(Map<String, dynamic> payment) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Refund'),
        content: Text(
          'Are you sure you want to refund ₹${payment['amount']} to ${payment['userName']}? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Refund', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      // Process refund (mock)
      setState(() {
        final index = _payments.indexWhere((p) => p['paymentId'] == payment['paymentId']);
        if (index != -1) {
          _payments[index]['status'] = 'refunded';
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refund initiated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
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

  Widget _paymentDetailItem(String label, String value) {
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_top;
      case 'failed':
        return Icons.cancel;
      case 'refunded':
        return Icons.replay;
      default:
        return Icons.payment;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }
}

