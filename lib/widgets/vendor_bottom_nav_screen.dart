import 'package:eventhorizon/screens/vendor_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventhorizon/screens/user_home_screen.dart';
import 'package:eventhorizon/screens/user_events_screen.dart';
import 'package:eventhorizon/screens/user_vendor_bookings_screen.dart';
import 'package:eventhorizon/screens/user_messages_screen.dart';
import 'package:eventhorizon/screens/user_profile_screen.dart';

class VendorDashboard extends StatelessWidget {
  const VendorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const VendorBottomNavScreen();  // Wrap VendorDashboard with VendorBottomNavScreen
  }
}

class VendorBottomNavScreen extends StatefulWidget {
  const VendorBottomNavScreen({super.key});

  @override
  _VendorBottomNavScreenState createState() => _VendorBottomNavScreenState();
}

class _VendorBottomNavScreenState extends State<VendorBottomNavScreen> {
  int _selectedIndex = 0;

  // List of screens for Vendor
  final List<Widget> _screens = [
    const HomeScreen(), // Vendor Home Screen
    const EventScreen(), // Vendor Search Screen
    const VendorBookingsScreen(), // Vendor Bookings Screen
    const ChatListScreen(), // Vendor Messages Screen
    const VendorProfileScreen(), // Vendor Profile Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
      ),
      body: _screens[_selectedIndex],  // Show selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,  // Active icon color
        unselectedItemColor: Colors.grey,  // Inactive icon color
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
