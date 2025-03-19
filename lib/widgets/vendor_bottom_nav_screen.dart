import 'package:eventhorizon/screens/vendor_home_screen.dart';
import 'package:eventhorizon/screens/vendor_search_screen.dart';
import 'package:eventhorizon/screens/vendor_bookings_screen.dart';
import 'package:eventhorizon/screens/vendor_messages_screen.dart';
import 'package:eventhorizon/screens/vendor_profile_screen.dart';
import 'package:flutter/material.dart';

class VendorDashboard extends StatelessWidget {
  final int initialIndex;

  const VendorDashboard({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return VendorBottomNavScreen(initialIndex: initialIndex);
  }
}

class VendorBottomNavScreen extends StatefulWidget {
  final int initialIndex;

  const VendorBottomNavScreen({super.key, this.initialIndex = 0});

  @override
  _VendorBottomNavScreenState createState() => _VendorBottomNavScreenState();
}

class _VendorBottomNavScreenState extends State<VendorBottomNavScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const VendorHomeScreen(),
      const VendorSearchScreen(), // Added Analytics Screen
      const VendorBookingsScreen(),
      const VendorMessagesScreen(),
      const VendorProfileScreen(vendorIndex: 0),
    ];

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
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Analytics"), // Updated icon & label
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
