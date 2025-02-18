import 'package:flutter/material.dart';

class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [Icon(Icons.more_vert, color: Colors.grey)],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 16),
            _buildServicesSection(),
            const SizedBox(height: 16),
            _buildPortfolioGrid(),
            const SizedBox(height: 16),
            _buildContactInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              "https://storage.googleapis.com/a1aa/image/Pb6FWzcRzBLYGzQ40URCBIxsSIr4ZsbQaHF0_hv9KDw.jpg",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Studio Creative", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < 4 ? Icons.star : Icons.star_half,
                      color: Colors.yellow[700],
                      size: 18,
                    );
                  }),
                ),
                const Text("Professional Photography", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
            child: const Text("Active", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(Icons.calendar_today, "New Bookings", "3"),
        _buildStatCard(Icons.star, "Pending Reviews", "2"),
        _buildStatCard(Icons.attach_money, "Total Revenue", "\$2,450"),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: _boxDecoration(),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Services", "Edit"),
          _buildServiceItem("Wedding Photography", "\$299/hr", true),
          _buildServiceItem("Corporate Events", "\$199/hr", true),
          _buildServiceItem("Portrait Sessions", "\$149/hr", false),
          const SizedBox(height: 8),
          _buildAddServiceButton(),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String title, String price, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(price, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Switch(value: isActive, onChanged: (value) {}),
        ],
      ),
    );
  }

  Widget _buildAddServiceButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
      child: const Text("+ Add New Service", style: TextStyle(color: Colors.blue)),
    );
  }

  Widget _buildPortfolioGrid() {
    List<String> images = [
      "https://storage.googleapis.com/a1aa/image/WNH0kbuxgC1umacs04ib_xDB1OP3UJ0eJnfCUYglbvA.jpg",
      "https://storage.googleapis.com/a1aa/image/txhIM5NoBKiI7vSRfxYMZYVlk1B2kCAbWkf2v_PbaE4.jpg",
      "https://storage.googleapis.com/a1aa/image/EiQyZFgOwmTLZzTvgqxTBhQjMMj5FnBcx0OkHKGTyEc.jpg",
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Portfolio", "12/50 photos"),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(images[index], fit: BoxFit.cover),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildAddServiceButton(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Contact Information", ""),
          _buildContactItem(Icons.email, "contact@studiocreative.com"),
          _buildContactItem(Icons.phone, "+1 (555) 123-4567"),
          _buildContactItem(Icons.location_on, "123 Creative St, Art City"),
          _buildContactItem(Icons.public, "www.studiocreative.com"),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String info) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(info, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(action, style: const TextStyle(color: Colors.blue)),
      ],
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)]);
  }
}
