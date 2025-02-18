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

class _VendorBookingsScreenState extends State<VendorBookingsScreen> {
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
    ),
    NotificationItem(
      name: "John Cooper",
      timeAgo: "15 mins ago",
      service: "Beard Trim",
      schedule: "Tomorrow, 11:30 AM",
      location: "Main Street Barbershop",
      price: "\$35.00",
      imageUrl: "https://placehold.co/40x40",
    ),
    NotificationItem(
      name: "Emma Wilson",
      timeAgo: "1 hour ago",
      service: "Manicure",
      schedule: "Feb 15, 2:00 PM",
      location: "Beauty Corner",
      price: "\$45.00",
      imageUrl: "https://placehold.co/40x40",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Background color
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: notifications.map((notification) {
            return _buildNotificationCard(context, notification);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem notification) {
    return GestureDetector(
      onTap: () {
        // Navigate to BookingRequestsPage and pass the data
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(notification.imageUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(notification.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text("New Request", style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(notification.service, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(notification.schedule, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Text(notification.location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(notification.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    _buildActionButton(context, "Accept", Colors.blue, Icons.check, true, notification),
                    const SizedBox(width: 8),
                    _buildActionButton(context, "Reject", Colors.grey, Icons.close, false, notification),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, Color color, IconData icon, bool isAccept, NotificationItem notification) {
    return ElevatedButton.icon(
      onPressed: () {
        if (isAccept) {
          // Navigate to the BookingRequestsPage with the details
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
        } else {
          // Show confirmation dialog for Reject
          _showRejectDialog(context, notification);
        }
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, NotificationItem notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to reject this booking request?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Remove the notification from the list
                  notifications.remove(notification);
                });
                Navigator.of(context).pop();  // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Booking Rejected!")),
                );
              },
              child: const Text('Yes'),
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

  NotificationItem({
    required this.name,
    required this.timeAgo,
    required this.service,
    required this.schedule,
    required this.location,
    required this.price,
    required this.imageUrl,
  });
}
