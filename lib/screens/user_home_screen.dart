import 'package:flutter/material.dart';
import 'User_CreateEventScreen.dart';
import 'package:eventhorizon/widgets/user_bottom_nav_screen.dart'; // Import the BottomNavScreen (or any other screen)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> events = []; // Store events here

  // Function to navigate to CreateEventScreen and receive event data
  Future<void> _navigateToCreateEventScreen(BuildContext context) async {
    final newEvent = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );

    if (newEvent != null) {
      setState(() {
        // Add the new event to the list
        events.add(newEvent);
      });
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
              _buildCreateEventSection(context), // Pass context to handle navigation
              const SizedBox(height: 20),
              _buildEventsAndBudget(),
              const SizedBox(height: 20),
              _buildCreatedEvents(), // Display created events
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
              backgroundImage: NetworkImage("https://storage.googleapis.com/a1aa/image/v9DaEqSqy7puzZasD8e_nSyNJ8ok4ejZgyDLaXZHhOQ.jpg"),
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

  Widget _buildCreateEventSection(BuildContext context) {
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
                  _customButton(
                      "Create New Event", Colors.purple, Colors.white, context),
                  const SizedBox(width: 10),
                  _browseVendorsButton(context), // Changed this to the Browse Vendors button
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customButton(String text, Color bgColor, Color textColor, BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
      onPressed: () => _navigateToCreateEventScreen(context),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  // Updated Browse Vendors button to navigate using pushReplacement
  Widget _browseVendorsButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavScreen(initialIndex: 2), // Correct usage
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.purple,
      ),
      child: const Text("Browse Vendors"),
    );
  }

  Widget _buildEventsAndBudget() {
    return Row(
      children: [
        _infoCard(Icons.calendar_today, "My Events", "2 upcoming events",
            Colors.purple),
        const SizedBox(width: 10),
        _infoCard(Icons.attach_money, "Budget Overview", "\$5,000 / \$8,000",
            Colors.blue),
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

  // Display created events
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
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this section
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4, // Adds shadow effect
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display event image at the top with the loading and error handlers
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.network(
                    event['image_url'] ?? "https://via.placeholder.com/150", // Default image if null
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, size: 50); // Placeholder if image fails
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    event['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${event['date']} at ${event['time']} - ${event['location']}",
                  ),
                  leading: const Icon(Icons.event, color: Colors.purple),
                  trailing: const Icon(Icons.arrow_forward, color: Colors.grey),
                  onTap: () {
                    // Navigate to event details screen
                  },
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}


}
