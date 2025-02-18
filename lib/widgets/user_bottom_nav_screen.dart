import 'package:flutter/material.dart';
import 'package:eventhorizon/screens/user_home_screen.dart';
import 'package:eventhorizon/screens/user_events_screen.dart';
import 'package:eventhorizon/screens/user_vendor_bookings_screen.dart';
import 'package:eventhorizon/screens/user_messages_screen.dart';
import 'package:eventhorizon/screens/user_profile_screen.dart';

class BottomNavScreen extends StatefulWidget {
  final int initialIndex; // Add this parameter

  const BottomNavScreen({super.key, this.initialIndex = 0}); // Update constructor

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventScreen(),
    const VendorBookingsScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set initial tab index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
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
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
