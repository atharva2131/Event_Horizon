import 'package:flutter/material.dart';

class VendorBookingsScreen extends StatelessWidget {
  const VendorBookingsScreen({super.key});

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
          children: [
            _buildNotificationCard(
              name: "Sarah Miller",
              timeAgo: "2 mins ago",
              service: "Hair Styling",
              schedule: "Today, 3:00 PM",
              location: "Downtown Salon",
              price: "\$75.00",
              imageUrl: "https://placehold.co/40x40",
            ),
            _buildNotificationCard(
              name: "John Cooper",
              timeAgo: "15 mins ago",
              service: "Beard Trim",
              schedule: "Tomorrow, 11:30 AM",
              location: "Main Street Barbershop",
              price: "\$35.00",
              imageUrl: "https://placehold.co/40x40",
            ),
            _buildNotificationCard(
              name: "Emma Wilson",
              timeAgo: "1 hour ago",
              service: "Manicure",
              schedule: "Feb 15, 2:00 PM",
              location: "Beauty Corner",
              price: "\$45.00",
              imageUrl: "https://placehold.co/40x40",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String name,
    required String timeAgo,
    required String service,
    required String schedule,
    required String location,
    required String price,
    required String imageUrl,
  }) {
    return Container(
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
          // Header: Profile Picture + Name + Time + Badge
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
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

          // Service Details
          Text(service, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(schedule, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(location, style: const TextStyle(color: Colors.grey, fontSize: 14)),

          const SizedBox(height: 10),

          // Price & Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildActionButton("Accept", Colors.blue, Icons.check),
                  const SizedBox(width: 8),
                  _buildActionButton("Reject", Colors.grey, Icons.close),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {}, // Add functionality here
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
}
