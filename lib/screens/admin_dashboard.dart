// admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eventhorizon/screens/admin_reports_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
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

  void _onItemTapped(int index) {
    if (index == 5) {
      // Navigate to Reports screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminReportScreen()),
      );
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    // In a real app, this would clear authentication tokens
    // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
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
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Vendors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          
          // Stats Cards
          _buildStatsGrid(),
          
          const SizedBox(height: 24),
          
          // Revenue Chart
          _buildRevenueChart(),
          
          const SizedBox(height: 24),
          
          // Recent Activities
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child: Text(
              _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
              style: TextStyle(
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 24,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Here\'s what\'s happening today',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadDashboardData();
              },
              tooltip: 'Refresh Data',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
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
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Overview',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This Year',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(mainLineChartData()),
          ),
        ],
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
        drawVerticalLine: false,
        horizontalInterval: 10000,
        getDrawingHorizontalLine: (value) {
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
              
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  monthLabels[index],
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10000,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '₹${value.toInt() / 1000}k',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: spots.length - 1.0,
      minY: 0,
      maxY: 60000,
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
            show: false,
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

  Widget _buildRecentActivities() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dashboardData['recentActivities']?.length ?? 0,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.withOpacity(0.2),
              height: 24,
            ),
            itemBuilder: (context, index) {
              if (_dashboardData['recentActivities'] == null) {
                return const ListTile(
                  title: Text('No recent activities'),
                );
              }
              
              final activity = _dashboardData['recentActivities'][index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getActivityIcon(activity['type']),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] ?? 'Activity',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['description'] ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity['time'] ?? '',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
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
    );
  }

  Widget _getActivityIcon(String activityType) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (activityType) {
      case 'user':
        iconData = Icons.person;
        iconColor = Colors.blue;
        bgColor = Colors.blue.withOpacity(0.1);
        break;
      case 'vendor':
        iconData = Icons.store;
        iconColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
        break;
      case 'booking':
        iconData = Icons.event;
        iconColor = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.1);
        break;
      case 'payment':
        iconData = Icons.payment;
        iconColor = Colors.purple;
        bgColor = Colors.purple.withOpacity(0.1);
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        bgColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}