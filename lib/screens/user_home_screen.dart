import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:eventhorizon/screens/budget_tracker_screen.dart';
import 'package:eventhorizon/screens/event_timeline_screen.dart';
import 'package:eventhorizon/screens/User_CreateEventScreen.dart';
import 'package:eventhorizon/widgets/user_bottom_nav_screen.dart';
import 'package:eventhorizon/screens/EventDetailScreen.dart';
import '../services/event_service.dart';
import '../services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Define the deep purple color as a constant for consistent usage
  final Color primaryColor = Colors.deepPurple;
  final Color primaryLightColor = Colors.deepPurple[100]!;
  
  List<Map<String, dynamic>> events = [];
  Map<String, dynamic> userProfile = {
    'name': 'User',
    'avatar_url': 'https://via.placeholder.com/150',
  };
  bool isLoading = true;
  String? errorMessage;
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadEvents();
  }

  Future<void> _loadUserProfile() async {
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
      
      // Use the ApiService instead of direct http call
      final response = await ApiService.get('/auth/me');
      
      if (response != null && response['user'] != null) {
        setState(() {
          userProfile = response['user'];
          isLoading = false;
        });
      } else {
        setState(() {
          // Keep default profile but don't show error
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        // Don't show error to user, just use default profile
        isLoading = false;
      });
    }
  }

  // Only updating the _loadEvents method to properly handle events and images

Future<void> _loadEvents() async {
  setState(() => isLoading = true);
  try {
    print('Loading events...');
    // Get events from the API
    final apiEvents = await _eventService.getEvents();
    print('Loaded ${apiEvents.length} events from API');
    
    // Process each event to ensure image URLs are correct
    for (var event in apiEvents) {
      if (event['image_url'] != null && event['image_url'].isNotEmpty) {
        print('Event ${event['name']} has image: ${event['image_url']}');
        
        // Ensure image URL is properly formatted
        if (!event['image_url'].startsWith('http')) {
          // If it's a local file path, check if it exists
          final file = File(event['image_url']);
          if (await file.exists()) {
            print('Image file exists locally: ${event['image_url']}');
          } else {
            // If not a valid local file, try to construct a full URL
            event['image_url'] = '${ApiService.baseUrl}${event['image_url']}';
            print('Constructed full URL: ${event['image_url']}');
          }
        }
      } else {
        print('Event ${event['name']} has no image');
      }
    }
    
    setState(() {
      events = apiEvents;
      isLoading = false;
    });
    
    print('Events set in state: ${events.length}');
  } catch (e) {
    print('Error loading events: $e');
    setState(() {
      events = []; // Set empty events list
      isLoading = false;
    });
  }
}

  Future<void> _navigateToCreateEventScreen(BuildContext context) async {
    final newEvent = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );

    if (newEvent != null) {
      // Refresh events list
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 0, // Hide the app bar but keep the status bar color
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
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
                          onPressed: () {
                            _loadUserProfile();
                            _loadEvents();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCreateEventSection(),
                              const SizedBox(height: 24),
                              _buildEventsAndBudget(context),
                              const SizedBox(height: 24),
                              _buildCreatedEvents(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateEventScreen(context),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    // Extract first name safely
    String firstName = 'User';
    if (userProfile['name'] != null && userProfile['name'].toString().isNotEmpty) {
      firstName = userProfile['name'].toString().split(' ')[0];
    }
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    userProfile['avatar_url'] ?? "https://via.placeholder.com/150",
                  ),
                  radius: 25,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, $firstName!",
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Let's plan your next event",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateEventSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              "https://storage.googleapis.com/a1aa/image/SJBqJLMbS-oJ-KERt70N94Qu2f2dK4LRYi-CFDWozww.jpg",
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  color: primaryLightColor,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.white),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Your Dream Event",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Plan, organize, and celebrate moments that matter",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _customButton("Create New Event", primaryColor, Colors.white),
                      const SizedBox(width: 12),
                      _browseVendorsButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customButton(String text, Color bgColor, Color textColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      onPressed: () => _navigateToCreateEventScreen(context),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
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
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Browse Vendors",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEventsAndBudget(BuildContext context) {
    // Get event counts from user profile or default to 0
    final upcomingEvents = events.where((e) {
      try {
        final dateParts = e['date'].split('/');
        final eventDate = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );
        return eventDate.isAfter(DateTime.now());
      } catch (e) {
        return false;
      }
    }).length;
    
    // Calculate budget used and total
    double budgetUsed = 0;
    double totalBudget = 0;
    
    for (var event in events) {
      if (event['budget'] != null && event['budget'].toString().isNotEmpty) {
        totalBudget += double.tryParse(event['budget'].toString()) ?? 0;
        // Assume 50% of budget is used for demo purposes
        budgetUsed += (double.tryParse(event['budget'].toString()) ?? 0) * 0.5;
      }
    }
    
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            Icons.calendar_today,
            "My Events",
            "$upcomingEvents upcoming events",
            primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BudgetTrackerScreen()),
              );
            },
            child: _infoCard(
              Icons.attach_money,
              "Budget",
              "\$${budgetUsed.toStringAsFixed(0)} / \$${totalBudget.toStringAsFixed(0)}",
              Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventTimelineScreen()),
              );
            },
            child: _infoCard(
              Icons.timeline,
              "Timeline",
              "View schedule",
              Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(IconData icon, String title, String subtitle, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCreatedEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Created Events",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all events
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        events.isEmpty
            ? _buildEmptyEventsState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(
                            event: event,
                          ),
                        ),
                      ).then((value) {
                        if (value != null && value is Map<String, dynamic>) {
                          // Refresh events list after returning from detail screen
                          _loadEvents();
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: _displayEventImage(event['image_url']),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['name'] ?? "Unnamed Event",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      event['date'] ?? "No date set",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        event['location'] ?? "No location set",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (event['guests'] != null && (event['guests'] as List).isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${(event['guests'] as List).length} guests",
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
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyEventsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: primaryLightColor,
          ),
          const SizedBox(height: 16),
          const Text(
            "No events created yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the + button to create your first event",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayEventImage(String? imageUrl) {
  print('Displaying image: $imageUrl');
  
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(
      width: double.infinity,
      height: 180,
      color: primaryLightColor,
      child: Icon(
        Icons.image,
        size: 64,
        color: primaryColor,
      ),
    );
  } else if (imageUrl.startsWith("http")) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading network image: $error');
        return Container(
          width: double.infinity,
          height: 180,
          color: primaryLightColor,
          child: Icon(
            Icons.broken_image,
            size: 64,
            color: primaryColor,
          ),
        );
      },
    );
  } else {
    // Try to load as a local file
    return Image.file(
      File(imageUrl),
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading file image: $error');
        // If local file fails, try as a relative URL
        return Image.network(
          '${ApiService.baseUrl}$imageUrl',
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              width: double.infinity,
              height: 180,
              color: primaryLightColor,
              child: Icon(
                Icons.broken_image,
                size: 64,
                color: primaryColor,
              ),
            );
          },
        );
      },
    );
  }
}
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}