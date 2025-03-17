import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eventhorizon/screens/admin_users.dart';
import 'package:eventhorizon/screens/admin_bookings.dart';
import 'package:eventhorizon/screens/admin_vendors.dart';
import 'package:eventhorizon/screens/admin_payments.dart';
import 'package:eventhorizon/screens/admin_reports.dart';
import 'package:eventhorizon/screens/admin_login.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = false;
  String _adminName = "Admin User";
  Map<String, dynamic> _dashboardData = {};
  int _selectedIndex = 0;

  // List of pages for the bottom navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    
    // Initialize pages
    _pages = [
      dashboardPage(),
      const AdminUsersScreen(),
      const AdminVendorsScreen(),
      const AdminBookingsScreen(),
      const AdminPaymentsScreen(),
      const AdminReportScreen()
    ];
  }

  void _loadMockData() {
    // Mock dashboard data
    _dashboardData = {
      'totalUsers': 1245,
      'activeVendors': 87,
      'pendingBookings': 32,
      'totalRevenue': 245000,
      'monthlyRevenue': [15000, 22000, 18500, 25000, 30000, 28000, 35000, 40000, 38000, 42000, 45000, 50000],
      'recentActivities': [
        {
          'type': 'user',
          'title': 'New User Registration',
          'description': 'John Doe registered as a new user',
          'time': '2 hours ago'
        },
        {
          'type': 'vendor',
          'title': 'Vendor Approved',
          'description': 'Elegant Events was approved as a vendor',
          'time': '3 hours ago'
        },
        {
          'type': 'booking',
          'title': 'New Booking',
          'description': 'Wedding ceremony booked at Grand Plaza',
          'time': '5 hours ago'
        },
        {
          'type': 'payment',
          'title': 'Payment Received',
          'description': '₹25,000 received for booking #1234',
          'time': '6 hours ago'
        },
        {
          'type': 'user',
          'title': 'User Profile Updated',
          'description': 'Sarah Johnson updated her profile information',
          'time': '8 hours ago'
        }
      ]
    };
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    // In a real app, this would clear authentication tokens
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EventHorizon Admin',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: Colors.deepPurple.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.store),
            label: 'Vendors',
          ),
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget dashboardPage() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        radius: 25,
                        child: Text(
                          _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $_adminName',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Here\'s what\'s happening today',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadMockData,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats Cards
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      'Total Users',
                      _dashboardData['totalUsers']?.toString() ?? '0',
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Active Vendors',
                      _dashboardData['activeVendors']?.toString() ?? '0',
                      Icons.store,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Pending Bookings',
                      _dashboardData['pendingBookings']?.toString() ?? '0',
                      Icons.event,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Total Revenue',
                      '₹${_dashboardData['totalRevenue']?.toString() ?? '0'}',
                      Icons.currency_rupee,
                      Colors.purple,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Revenue Chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue Overview',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(mainLineChartData()),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Recent Activities
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activities',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _dashboardData['recentActivities']?.length ?? 0,
                        itemBuilder: (context, index) {
                          if (_dashboardData['recentActivities'] == null) {
                            return const ListTile(
                              title: Text('No recent activities'),
                            );
                          }
                          
                          final activity = _dashboardData['recentActivities'][index];
                          return ListTile(
                            leading: _getActivityIcon(activity['type']),
                            title: Text(activity['title'] ?? 'Activity'),
                            subtitle: Text(activity['description'] ?? ''),
                            trailing: Text(
                              activity['time'] ?? '',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        },
                      ),
                      if (_dashboardData['recentActivities'] == null || _dashboardData['recentActivities'].isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text('No recent activities'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainLineChartData() {
    List<FlSpot> spots = [];
    
    // Check if we have monthly revenue data
    if (_dashboardData['monthlyRevenue'] != null) {
      final monthlyRevenue = _dashboardData['monthlyRevenue'] as List;
      for (int i = 0; i < monthlyRevenue.length; i++) {
        spots.add(FlSpot(i.toDouble(), monthlyRevenue[i].toDouble()));
      }
    } else {
      // Sample data if not available
      spots = [
        const FlSpot(0, 3000),
        const FlSpot(1, 4500),
        const FlSpot(2, 3800),
        const FlSpot(3, 5000),
        const FlSpot(4, 4200),
        const FlSpot(5, 6000),
      ];
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1000,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const monthLabels = [
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
              ];
              final index = value.toInt();
              
              if (index < 0 || index >= monthLabels.length) {
                return const Text('');
              }
              
              return Text(
                monthLabels[index],
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1000,
            getTitlesWidget: (value, meta) {
              return Text(
                '₹${value.toInt()}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      minX: 0,
      maxX: spots.length - 1.0,
      minY: 0,
      maxY: 7000,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade200,
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade200.withOpacity(0.3),
                Colors.deepPurple.shade100.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getActivityIcon(String activityType) {
    IconData iconData;
    Color iconColor;

    switch (activityType) {
      case 'user':
        iconData = Icons.person;
        iconColor = Colors.blue;
        break;
      case 'vendor':
        iconData = Icons.store;
        iconColor = Colors.green;
        break;
      case 'booking':
        iconData = Icons.event;
        iconColor = Colors.orange;
        break;
      case 'payment':
        iconData = Icons.payment;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}

