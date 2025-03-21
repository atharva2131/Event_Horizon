import 'package:flutter/material.dart';

class VendorSearchScreen extends StatefulWidget {
  const VendorSearchScreen({super.key});

  @override
  _VendorSearchScreenState createState() => _VendorSearchScreenState();
}

class _VendorSearchScreenState extends State<VendorSearchScreen> {
  String selectedPeriod = "Last 30 Days";

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
        title: const Text(
          "Analytics Dashboard",
          style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPeriod,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedPeriod = newValue;
                    });
                  }
                },
                items: analyticsData.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  );
                }).toList(),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
              ),
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
            _buildGraphSection("Booking Trends"),
            const SizedBox(height: 20),
            _buildPopularServices(),
            const SizedBox(height: 20),
            _buildCustomerFeedback(),
            const SizedBox(height: 20),
            _buildGraphSection("Monthly Revenue"),
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
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(Icons.event, "Bookings", data["bookings"]!, "+12.5%", Colors.blue),
        _buildStatCard(Icons.monetization_on, "Revenue", data["revenue"]!, "+8.2%", Colors.green),
        _buildStatCard(Icons.star, "Rating", data["rating"]!, "+0.3", Colors.amber),
        _buildStatCard(Icons.reviews, "Reviews", data["reviews"]!, "+22", Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, String growth, Color iconColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            Text(growth, style: const TextStyle(fontSize: 16, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphSection(String title) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(
                  child: Text("Graph Placeholder", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularServices() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Most Popular Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 10),
            _buildServiceProgress("Photography", "145 bookings | \$7250", 0.85),
            _buildServiceProgress("Catering", "123 bookings | \$4920", 0.75),
            _buildServiceProgress("Decoration", "98 bookings | \$2940", 0.6),
            _buildServiceProgress("DJ & Music", "87 bookings | \$3480", 0.55),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceProgress(String service, String details, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(service, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: Colors.deepPurple,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          Text(details, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCustomerFeedback() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Customer Feedback", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("4.8", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber, size: 30),
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
