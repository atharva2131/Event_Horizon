import 'package:flutter/material.dart';

class VendorSearchScreen extends StatefulWidget {
  const VendorSearchScreen({super.key});

  @override
  _VendorSearchScreenState createState() => _VendorSearchScreenState();
}

class _VendorSearchScreenState extends State<VendorSearchScreen> {
  String selectedPeriod = "Last 30 Days";

  // Mock Data for Different Time Periods
  Map<String, Map<String, String>> analyticsData = {
    "Last 7 Days": {"bookings": "120", "revenue": "\$6.5k", "rating": "4.7", "reviews": "85"},
    "Last 30 Days": {"bookings": "442", "revenue": "\$26.5k", "rating": "4.8", "reviews": "442"},
    "Last 3 Months": {"bookings": "1250", "revenue": "\$78k", "rating": "4.9", "reviews": "1230"},
    "Last Year": {"bookings": "5200", "revenue": "\$320k", "rating": "4.8", "reviews": "5200"},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Analytics Dashboard"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: selectedPeriod,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedPeriod = newValue;
                  });
                }
              },
              items: <String>["Last 7 Days", "Last 30 Days", "Last 3 Months", "Last Year"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              dropdownColor: Colors.white,
              underline: Container(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCards(),
            const SizedBox(height: 20),
            _buildSection("Booking Trends",
                "https://storage.googleapis.com/a1aa/image/CLZFwo_XuEDdqjdeea7YMgpDknA21fS8VH0tayzQhMY.jpg"),
            const SizedBox(height: 20),
            _buildPopularServices(),
            const SizedBox(height: 20),
            _buildCustomerFeedback(),
            const SizedBox(height: 20),
            _buildSection("Monthly Revenue",
                "https://storage.googleapis.com/a1aa/image/oS8XZ_tTkp2bguhlWhFGDXGFcyVfQvnVlbncgOjtK1E.jpg"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    var data = analyticsData[selectedPeriod] ?? analyticsData["Last 30 Days"]!;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildStatCard(Icons.show_chart, "Bookings", data["bookings"]!, "+12.5%", Colors.blue),
        _buildStatCard(Icons.attach_money, "Revenue", data["revenue"]!, "+8.2%", Colors.green),
        _buildStatCard(Icons.star, "Rating", data["rating"]!, "+0.3", Colors.yellow),
        _buildStatCard(Icons.comment, "Reviews", data["reviews"]!, "+22", Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, String growth, Color iconColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 30),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(growth, style: const TextStyle(fontSize: 16, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String imageUrl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularServices() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Most Popular Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildServiceProgress("Deep Cleaning", "145 bookings \$7250", 0.8),
            _buildServiceProgress("Regular Cleaning", "123 bookings \$4920", 0.7),
            _buildServiceProgress("Window Cleaning", "98 bookings \$2940", 0.5),
            _buildServiceProgress("Carpet Cleaning", "87 bookings \$3480", 0.6),
            _buildServiceProgress("Move-in Cleaning", "76 bookings \$3800", 0.4),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceProgress(String service, String details, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(service, style: const TextStyle(fontSize: 16)),
              Text(details, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerFeedback() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Customer Feedback",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("4.8", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.yellow, size: 30),
              ],
            ),
            const SizedBox(height: 10),
            const Text("442 reviews", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
