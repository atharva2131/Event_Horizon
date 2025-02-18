import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'User_CreateEventScreen.dart';
import 'user_vendor_bookings_screen.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          "https://storage.googleapis.com/a1aa/image/v9DaEqSqy7puzZasD8e_nSyNJ8ok4ejZgyDLaXZHhOQ.jpg",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Welcome back, Sarah!",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Let's plan your next event",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(FontAwesomeIcons.bell, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 20),

              // Event Creation Section
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://storage.googleapis.com/a1aa/image/SJBqJLMbS-oJ-KERt70N94Qu2f2dK4LRYi-CFDWozww.jpg",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Create Your Dream Event",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateEventScreen()),
                                );
                              },
                              child: const Text("Create New Event"),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const VendorBookingsScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.purple,
                              ),
                              child: const Text("Browse Vendors"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Event & Budget Overview
              Row(
                children: [
                  Expanded(
                    child: _infoCard(FontAwesomeIcons.calendarAlt, "My Events",
                        "2 upcoming events"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _infoCard(FontAwesomeIcons.clock, "Budget Overview",
                        "\$5,000 / \$8,000"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Popular Categories

              // Top Vendors
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Top Vendors",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("View All", style: TextStyle(color: Colors.purple)),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _vendorCard(
                        "Elegant Events",
                        "Wedding Planner",
                        "https://storage.googleapis.com/a1aa/image/N7V4-lXohbfhXolcc2uiPbQ2XxnR7Tz2AhVZA7kx94w.jpg",
                        4.8),
                    _vendorCard(
                        "Gourmet Delight",
                        "Catering",
                        "https://storage.googleapis.com/a1aa/image/ykuOARcvs-OPOWx4eLBtkhwxgDZvFO76e_u29TB8cNc.jpg",
                        4.9),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Event Timeline
              const Text("Event Timeline",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: [
                  _timelineItem(FontAwesomeIcons.check, "Book Wedding Venue",
                      "completed", "Mar 15", Colors.green),
                  _timelineItem(FontAwesomeIcons.check, "Select Catering Menu",
                      "in progress", "Mar 20", Colors.blue),
                  _timelineItem(FontAwesomeIcons.check, "Send Invitations",
                      "upcoming", "Mar 25", Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(height: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _vendorCard(
      String name, String category, String imageUrl, double rating) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl,
              height: 80, width: double.infinity, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(category, style: const TextStyle(color: Colors.grey)),
          Row(children: [
            const Icon(FontAwesomeIcons.star, color: Colors.yellow),
            Text(" $rating")
          ]),
        ],
      ),
    );
  }

  Widget _timelineItem(
      IconData icon, String title, String status, String date, Color color) {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color)),
      title: Text(title),
      subtitle: Text(status, style: TextStyle(color: Colors.grey)),
      trailing: Text(date, style: TextStyle(color: Colors.grey)),
    );
  }
}
