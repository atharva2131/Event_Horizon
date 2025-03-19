// admin_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({Key? key}) : super(key: key);

  @override
  _AdminReportScreenState createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDateRange = 'This Month';
  final currencyFormat = NumberFormat.currency(symbol: '₹');
  int _currentBottomNavIndex = 2; // Set to Reports tab by default
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Reports & Analytics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildDateRangeDropdown(),
          const SizedBox(width: 12),
          _buildExportButton(),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'User Growth'),
            Tab(text: 'Booking Trends'),
            Tab(text: 'Revenue'),
            Tab(text: 'Vendor Performance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUserGrowthTab(),
          _buildBookingTrendsTab(),
          _buildRevenueTab(),
          _buildVendorPerformanceTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      onTap: (index) {
        setState(() {
          _currentBottomNavIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Vendors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  Widget _buildDateRangeDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          setState(() {
            _selectedDateRange = value;
          });
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'Today', child: Text('Today')),
          const PopupMenuItem(value: 'This Week', child: Text('This Week')),
          const PopupMenuItem(value: 'This Month', child: Text('This Month')),
          const PopupMenuItem(value: 'This Quarter', child: Text('This Quarter')),
          const PopupMenuItem(value: 'This Year', child: Text('This Year')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _selectedDateRange,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download, size: 16),
        label: const Text('Export'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricCards(isTablet: isTablet),
              const SizedBox(height: 24),
              _buildRevenueChart(),
              const SizedBox(height: 24),
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildBookingCategoriesChart(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTopVendorsCard(),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildBookingCategoriesChart(),
                    const SizedBox(height: 16),
                    _buildTopVendorsCard(),
                  ],
                ),
              // Add some bottom padding to ensure content doesn't get hidden by bottom nav
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMetricCards({required bool isTablet}) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isTablet ? 1.5 : 1.3,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        final metrics = [
          {
            'title': 'Total Users',
            'value': '12,548',
            'change': '+16%',
            'icon': Icons.people,
            'color': Colors.blue,
          },
          {
            'title': 'Active Bookings',
            'value': '1,024',
            'change': '+12%',
            'icon': Icons.calendar_today,
            'color': Colors.orange,
          },
          {
            'title': 'Monthly Revenue',
            'value': currencyFormat.format(89452),
            'change': '+8%',
            'icon': Icons.trending_up,
            'color': Colors.green,
          },
          {
            'title': 'Vendor Satisfaction',
            'value': '94.2%',
            'change': '+2.4%',
            'icon': Icons.thumb_up,
            'color': Colors.purple,
          },
        ];
        
        return _buildMetricCard(
          title: metrics[index]['title'] as String,
          value: metrics[index]['value'] as String,
          change: metrics[index]['change'] as String,
          icon: metrics[index]['icon'] as IconData,
          color: metrics[index]['color'] as Color,
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'from last month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Overview',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                    ),
                    Text(
                      'Monthly revenue breakdown for $_selectedDateRange',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+12.5%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          final index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                months[index],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              currencyFormat.format(value),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: 100000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 35000),
                        FlSpot(1, 42000),
                        FlSpot(2, 55000),
                        FlSpot(3, 48000),
                        FlSpot(4, 52000),
                        FlSpot(5, 60000),
                        FlSpot(6, 62000),
                        FlSpot(7, 65000),
                        FlSpot(8, 68000),
                        FlSpot(9, 75000),
                        FlSpot(10, 82000),
                        FlSpot(11, 89000),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple,
                          Colors.deepPurple.withOpacity(0.5),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.deepPurple,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.withOpacity(0.3),
                            Colors.deepPurple.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCategoriesChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Categories',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            Text(
              'Distribution by event type',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.5,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: 35,
                      title: '35%',
                      color: Colors.deepPurple,
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      titlePositionPercentageOffset: 0.55,
                    ),
                    PieChartSectionData(
                      value: 25,
                      title: '25%',
                      color: Colors.deepPurple[300],
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      titlePositionPercentageOffset: 0.55,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: '20%',
                      color: Colors.deepPurple[200],
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      titlePositionPercentageOffset: 0.55,
                    ),
                    PieChartSectionData(
                      value: 15,
                      title: '15%',
                      color: Colors.deepPurple[100],
                      radius: 80,
                      titleStyle: TextStyle(
                        color: Colors.deepPurple[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      titlePositionPercentageOffset: 0.55,
                    ),
                    PieChartSectionData(
                      value: 5,
                      title: '5%',
                      color: Colors.deepPurple[50],
                      radius: 80,
                      titleStyle: TextStyle(
                        color: Colors.deepPurple[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      titlePositionPercentageOffset: 0.55,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem('Weddings', Colors.deepPurple),
                _buildLegendItem('Corporate', Colors.deepPurple[300]!),
                _buildLegendItem('Birthdays', Colors.deepPurple[200]!),
                _buildLegendItem('Concerts', Colors.deepPurple[100]!),
                _buildLegendItem('Others', Colors.deepPurple[50]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopVendorsCard() {
    final vendors = [
      {'name': 'Elegant Events', 'bookings': 124, 'rating': 4.9},
      {'name': 'Luxe Catering', 'bookings': 98, 'rating': 4.8},
      {'name': 'Bloom Decor', 'bookings': 87, 'rating': 4.7},
      {'name': 'Sound Masters', 'bookings': 76, 'rating': 4.7},
      {'name': 'Capture Moments', 'bookings': 65, 'rating': 4.6},
    ];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Performing Vendors',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                    ),
                    Text(
                      'Based on bookings and ratings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[700],
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vendors.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.withOpacity(0.2),
                height: 24,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            vendors[index]['name'].toString()[0],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendors[index]['name'] as String,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple[800],
                              ),
                            ),
                            Text(
                              '${vendors[index]['bookings']} bookings',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${vendors[index]['rating']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[800],
                              ),
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
        ),
      ),
    );
  }

  Widget _buildUserGrowthTab() {
    return _buildPlaceholderTab(
      icon: Icons.people,
      title: 'User Growth Analytics',
      description: 'New registrations and engagement metrics',
    );
  }

  Widget _buildBookingTrendsTab() {
    return _buildPlaceholderTab(
      icon: Icons.calendar_today,
      title: 'Booking Trends',
      description: 'Peak seasons and popular services',
    );
  }

  Widget _buildRevenueTab() {
    return _buildPlaceholderTab(
      icon: Icons.trending_up,
      title: 'Revenue Reports',
      description: 'Monthly and yearly earnings breakdown',
    );
  }

  Widget _buildVendorPerformanceTab() {
    return _buildPlaceholderTab(
      icon: Icons.store,
      title: 'Vendor Performance Analytics',
      description: 'Identify high-performing vendors',
    );
  }

  Widget _buildPlaceholderTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: Colors.deepPurple[300],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Add bottom padding to avoid content being hidden by bottom nav
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}