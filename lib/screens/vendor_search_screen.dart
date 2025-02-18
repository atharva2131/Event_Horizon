import 'package:flutter/material.dart';

class VendorSearchScreen extends StatelessWidget {
  const VendorSearchScreen({super.key});

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
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                children: [
                  Text("Last 30 Days"),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          )
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
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildStatCard(Icons.show_chart, "Bookings", "442", "+12.5%", Colors.blue),
        _buildStatCard(Icons.attach_money, "Revenue", "\$26.5k", "+8.2%", Colors.green),
        _buildStatCard(Icons.star, "Rating", "4.8", "+0.3", Colors.yellow),
        _buildStatCard(Icons.comment, "Reviews", "442", "+22", Colors.purple),
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
            const SizedBox(height: 10),
            _buildFeedbackBar(1, 8, 0.1),
            _buildFeedbackBar(2, 12, 0.2),
            _buildFeedbackBar(3, 45, 0.3),
            _buildFeedbackBar(4, 132, 0.6),
            _buildFeedbackBar(5, 245, 0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBar(int rating, int count, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rating.toString(), style: const TextStyle(fontSize: 16)),
              Text(count.toString(), style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
}
