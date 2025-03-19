import 'package:flutter/material.dart';
import 'package:eventhorizon/screens/vendor_home_screen.dart';
import 'package:eventhorizon/screens/vendor_search_screen.dart';
import 'package:eventhorizon/screens/vendor_bookings_screen.dart';
import 'package:eventhorizon/screens/vendor_messages_screen.dart';
import 'package:eventhorizon/screens/vendor_profile_screen.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  _VendorDashboardState createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
     VendorHomeScreen(),
    const VendorSearchScreen(),
    const VendorBookingsScreen(),
    const VendorMessagesScreen(),
      const VendorProfileScreen(vendorIndex: 0),
  ];

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
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
