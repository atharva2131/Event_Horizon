import 'package:flutter/material.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Michael Carter',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Professional Decor Vendor',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.star, color: Colors.amber),
                        Text('4.8 (95 reviews)', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatistic('18', 'Completed Projects'),
                  _buildStatistic('7', 'Ongoing Orders'),
                  _buildStatistic('\$35.6k', 'Earnings'),
                  _buildStatistic('4.8', 'Client Rating'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Active Collaborations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCollaborator('Sophia Lee', 'Florist', 'https://via.placeholder.com/150'),
                  _buildCollaborator('Daniel Smith', 'Lighting Expert', 'https://via.placeholder.com/150'),
                  _buildCollaborator('Emily Davis', 'Caterer', 'https://via.placeholder.com/150'),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Settings & Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildSettingOption('Account Settings'),
              _buildSettingOption('Notifications'),
              _buildSettingOption('Payment Methods'),
              _buildSettingOption('Help & Support'),
              _buildSettingOption('Privacy & Terms'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistic(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCollaborator(String name, String role, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 8),
          Text(name),
          Text(role, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingOption(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {},
    );
  }
}
