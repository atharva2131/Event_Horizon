import 'package:flutter/material.dart';
import 'BookingRequestsPage.dart'; // Import the new screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A148C), // Deep Purple 900
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A148C),
          primary: const Color(0xFF4A148C),
          secondary: const Color(0xFF7C43BD), // Lighter purple
          background: Colors.white,
        ),
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const VendorBookingsScreen(),
    );
  }
}

// Vendor Bookings Screen (Notification List)
class VendorBookingsScreen extends StatefulWidget {
  const VendorBookingsScreen({super.key});

  @override
  _VendorBookingsScreenState createState() => _VendorBookingsScreenState();
}

class _VendorBookingsScreenState extends State<VendorBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // List of notifications
  List<NotificationItem> notifications = [
    NotificationItem(
      name: "Sarah Miller",
      timeAgo: "2 mins ago",
      service: "Hair Styling",
      schedule: "Today, 3:00 PM",
      location: "Downtown Salon",
      price: "\$75.00",
      imageUrl: "https://placehold.co/40x40",
      status: "pending",
    ),
    NotificationItem(
      name: "John Cooper",
      timeAgo: "15 mins ago",
      service: "Beard Trim",
      schedule: "Tomorrow, 11:30 AM",
      location: "Main Street Barbershop",
      price: "\$35.00",
      imageUrl: "https://placehold.co/40x40",
      status: "pending",
    ),
    NotificationItem(
      name: "Emma Wilson",
      timeAgo: "1 hour ago",
      service: "Manicure",
      schedule: "Feb 15, 2:00 PM",
      location: "Beauty Corner",
      price: "\$45.00",
      imageUrl: "https://placehold.co/40x40",
      status: "pending",
    ),
    NotificationItem(
      name: "Michael Brown",
      timeAgo: "3 hours ago",
      service: "Full Body Massage",
      schedule: "Feb 16, 10:00 AM",
      location: "Wellness Spa",
      price: "\$120.00",
      imageUrl: "https://placehold.co/40x40",
      status: "pending",
    ),
  ];

  List<NotificationItem> acceptedBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text(
          "Booking Requests",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4A148C), // Deep Purple
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "New Requests"),
            Tab(text: "Accepted"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // New Requests Tab
          notifications.isEmpty
              ? _buildEmptyState("No new booking requests")
              : _buildNotificationList(notifications),

          // Accepted Tab
          acceptedBookings.isEmpty
              ? _buildEmptyState("No accepted bookings yet")
              : _buildNotificationList(acceptedBookings),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(context, items[index]);
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0FF), // Very light purple
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF4A148C).withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(notification.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: notification.status == "pending"
                        ? const Color(0xFF7C43BD).withOpacity(0.2)
                        : const Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    notification.status == "pending" ? "New Request" : "Accepted",
                    style: TextStyle(
                      color: notification.status == "pending"
                          ? const Color(0xFF7C43BD)
                          : const Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Service details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service type with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A148C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: Color(0xFF4A148C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.service,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Schedule and location info
                _buildInfoRow(Icons.calendar_today, notification.schedule),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, notification.location),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Price and action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Price: ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          notification.price,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A148C),
                          ),
                        ),
                      ],
                    ),
                    if (notification.status == "pending")
                      Row(
                        children: [
                          _buildActionButton(
                            context,
                            "Reject",
                            Colors.grey[300]!,
                            Colors.grey[700]!,
                            Icons.close,
                            false,
                            notification,
                          ),
                          const SizedBox(width: 10),
                          _buildActionButton(
                            context,
                            "Accept",
                            const Color(0xFF4A148C),
                            Colors.white,
                            Icons.check,
                            true,
                            notification,
                          ),
                        ],
                      ),
                    if (notification.status == "accepted")
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingRequestsPage(
                                name: notification.name,
                                service: notification.service,
                                schedule: notification.schedule,
                                location: notification.location,
                                price: notification.price,
                                imageUrl: notification.imageUrl,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text("View Details"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A148C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color backgroundColor,
    Color textColor,
    IconData icon,
    bool isAccept,
    NotificationItem notification,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        if (isAccept) {
          setState(() {
            // Update status
            notification.status = "accepted";

            // Remove from notifications and add to accepted
            notifications.remove(notification);
            acceptedBookings.add(notification);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Booking Accepted!"),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Show confirmation dialog for Reject
          _showRejectDialog(context, notification);
        }
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 0,
      ),
    );
  }

  void _showRejectDialog(BuildContext context, NotificationItem notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Reject Booking Request',
            style: TextStyle(
              color: Color(0xFF4A148C),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('Are you sure you want to reject this booking request?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Remove the notification from the list
                  notifications.remove(notification);
                });
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Booking Rejected"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A148C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}

// Notification Item class to hold the data
class NotificationItem {
  final String name;
  final String timeAgo;
  final String service;
  final String schedule;
  final String location;
  final String price;
  final String imageUrl;
  String status; // "pending" or "accepted"

  NotificationItem({
    required this.name,
    required this.timeAgo,
    required this.service,
    required this.schedule,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.status,
  });
}