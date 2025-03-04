import 'package:eventhorizon/screens/vendor_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventhorizon/screens/user_home_screen.dart';
import 'package:eventhorizon/screens/user_events_screen.dart';
import 'package:eventhorizon/screens/user_vendor_bookings_screen.dart';
import 'package:eventhorizon/screens/user_messages_screen.dart';

class VendorDashboard extends StatelessWidget {
  const VendorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const VendorBottomNavScreen(); // Wrap VendorDashboard with VendorBottomNavScreen
  }
}

class VendorBottomNavScreen extends StatefulWidget {
  final int initialIndex;

  const VendorBottomNavScreen({super.key, this.initialIndex = 0});

  @override
  _VendorBottomNavScreenState createState() => _VendorBottomNavScreenState();
}

class _VendorBottomNavScreenState extends State<VendorBottomNavScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set the initial index based on the passed parameter
  }

  final List<Widget> _screens = [
    const HomeScreen(), // Vendor Home Screen
    const EventScreen(), // Vendor Event Search Screen
    const VendorBookingsScreen(), // Vendor Bookings Screen
    const ChatListScreen(), // Vendor Messages Screen
    const VendorProfileScreen(vendorIndex: 0), // Vendor Profile Screen at index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple, // Active icon color
        unselectedItemColor: Colors.grey, // Inactive icon color
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped, // Handle the tap on bottom nav items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
