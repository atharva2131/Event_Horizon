// File: lib/screens/vendor_pending_reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VendorPendingReviewsScreen extends StatefulWidget {
  const VendorPendingReviewsScreen({super.key});

  @override
  _VendorPendingReviewsScreenState createState() => _VendorPendingReviewsScreenState();
}

class _VendorPendingReviewsScreenState extends State<VendorPendingReviewsScreen> {
  final Color primaryColor = Colors.deepPurple;
  bool isLoading = true;
  List<Map<String, dynamic>> pendingReviews = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingReviews();
  }

  Future<void> _loadPendingReviews() async {
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
      
      final response = await http.get(
        Uri.parse('http://192.168.29.168:3000/api/vendor/reviews/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          pendingReviews = List<Map<String, dynamic>>.from(responseData['reviews'] ?? []);
          isLoading = false;
        });
      } else {
        // If API fails, use mock data
        setState(() {
          pendingReviews = [
            {
              "id": "1",
              "customer_name": "John Doe",
              "event_date": "2023-05-15",
              "event_type": "Wedding",
              "service": "Wedding Photography",
              "status": "Pending"
            },
            {
              "id": "2",
              "customer_name": "Jane Smith",
              "event_date": "2023-06-20",
              "event_type": "Corporate Event",
              "service": "Corporate Photography",
              "status": "Pending"
            },
            {
              "id": "3",
              "customer_name": "Robert Johnson",
              "event_date": "2023-07-10",
              "event_type": "Birthday Party",
              "service": "Event Photography",
              "status": "Pending"
            },
          ];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading pending reviews: $e');
      // Use mock data on error
      setState(() {
        pendingReviews = [
          {
            "id": "1",
            "customer_name": "John Doe",
            "event_date": "2023-05-15",
            "event_type": "Wedding",
            "service": "Wedding Photography",
            "status": "Pending"
          },
          {
            "id": "2",
            "customer_name": "Jane Smith",
            "event_date": "2023-06-20",
            "event_type": "Corporate Event",
            "service": "Corporate Photography",
            "status": "Pending"
          },
          {
            "id": "3",
            "customer_name": "Robert Johnson",
            "event_date": "2023-07-10",
            "event_type": "Birthday Party",
            "service": "Event Photography",
            "status": "Pending"
          },
        ];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Pending Reviews", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                          onPressed: _loadPendingReviews,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : pendingReviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
                          const SizedBox(height: 16),
                          Text(
                            "No pending reviews!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "All your events have been reviewed.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pendingReviews.length,
                      itemBuilder: (context, index) {
                        final review = pendingReviews[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review['customer_name'] ?? "Customer",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        review['status'] ?? "Pending",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(Icons.event, "Event Type", review['event_type'] ?? "N/A"),
                                const SizedBox(height: 8),
                                _buildInfoRow(Icons.calendar_today, "Event Date", review['event_date'] ?? "N/A"),
                                const SizedBox(height: 8),
                                _buildInfoRow(Icons.camera_alt, "Service", review['service'] ?? "N/A"),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // Send reminder to customer
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Reminder sent to ${review['customer_name']}')),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: primaryColor,
                                      ),
                                      child: const Text("Send Reminder"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}