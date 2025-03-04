import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
<<<<<<< HEAD
=======
import 'User_CreateEventScreen.dart';
import 'package:eventhorizon/widgets/user_bottom_nav_screen.dart';
import 'package:eventhorizon/screens/budget_tracker_screen.dart'; 
import 'package:eventhorizon/screens/event_timeline_screen.dart';
>>>>>>> 7322382a034eda045a5d2b8eb1dc920318736118
import 'dart:io';
import 'User_CreateEventScreen.dart';
import 'package:eventhorizon/widgets/user_bottom_nav_screen.dart';
import 'EventDetailScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      setState(() {
        events = List<Map<String, dynamic>>.from(json.decode(eventsJson));
      });
    }
  }

  Future<void> _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventsJson = json.encode(events);
    prefs.setString('events', eventsJson);
  }

  Future<void> _navigateToCreateEventScreen(BuildContext context) async {
    final newEvent = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );

    if (newEvent != null) {
      setState(() {
        events.add(newEvent);
      });
      _saveEvents();
    }
  }

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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCreateEventSection(),
              const SizedBox(height: 20),
              _buildEventsAndBudget(context),
              const SizedBox(height: 20),
              _buildCreatedEvents(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://storage.googleapis.com/a1aa/image/v9DaEqSqy7puzZasD8e_nSyNJ8ok4ejZgyDLaXZHhOQ.jpg"),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Welcome back, Sarah!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Let's plan your next event",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const Icon(Icons.notifications, size: 28, color: Colors.grey),
      ],
    );
  }

  Widget _buildCreateEventSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            "https://storage.googleapis.com/a1aa/image/SJBqJLMbS-oJ-KERt70N94Qu2f2dK4LRYi-CFDWozww.jpg",
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _customButton("Create New Event", Colors.purple, Colors.white),
                  const SizedBox(width: 10),
                  _browseVendorsButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customButton(String text, Color bgColor, Color textColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
      onPressed: () => _navigateToCreateEventScreen(context),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  Widget _browseVendorsButton() {
    return OutlinedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavScreen(initialIndex: 2),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.purple,
      ),
      child: const Text("Browse Vendors"),
    );
  }

 Widget _buildEventsAndBudget(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures proper spacing
    children: [
      Expanded(
        child: _infoCard(Icons.calendar_today, "My Events", "2 upcoming events", Colors.purple),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: GestureDetector(
          onTap: () {
            // Navigate to BudgetTrackerScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BudgetTrackerScreen()),
            );
          },
          child: _infoCard(Icons.attach_money, "Budget Overview", "\$5,000 / \$8,000", Colors.blue),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: GestureDetector(
          onTap: () {
            // Navigate to EventTimelineScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventTimelineScreen()),
            );
          },
          child: _infoCard(Icons.timeline, "Event Timeline", "View event schedule", Colors.green),
        ),
      ),
    ],
  );
}



  Widget _infoCard(
      IconData icon, String title, String subtitle, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
        child: Column(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 5),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatedEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Created Events",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
<<<<<<< HEAD

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EventDetailScreen(event: Map<String, String>.from(event)),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _displayEventImage(event['image_url']),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        event['name'] ?? "Unnamed Event",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _displayEventImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset("assets/default_event.jpg",
          width: double.infinity, height: 150, fit: BoxFit.cover);
    } else if (imageUrl.startsWith("http")) {
      return Image.network(imageUrl,
          width: double.infinity, height: 150, fit: BoxFit.cover);
    } else {
      return Image.file(File(imageUrl),
          width: double.infinity, height: 150, fit: BoxFit.cover);
    }
  }
=======
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display event image at the top
                  if (event['image_url'] != null &&
                      event['image_url']!.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: _displayEventImage(event['image_url']!),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${event['date']} at ${event['time']} - ${event['location']}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

// Helper function to display event image properly
  Widget _displayEventImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 150,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50),
        ),
      );
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 150,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error, size: 50),
          ),
        ),
      );
    } else {
      return Image.file(
        File(imageUrl),
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
      );
    }
  }

  
>>>>>>> 7322382a034eda045a5d2b8eb1dc920318736118
}
