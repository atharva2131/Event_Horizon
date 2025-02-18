import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with your image URL
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sarah Anderson',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Senior Event Planner',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        Text(
                          '4.9 (128 reviews)',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatistic('12', 'Upcoming Events'),
                  _buildStatistic('5', 'Active Projects'),
                  _buildStatistic('\$24.8k', 'Total Revenue'),
                  _buildStatistic('4.9', 'Client Rating'),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Active Collaborations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  _buildCollaborator('Alex Kim', 'Photographer', 'https://via.placeholder.com/150'),
                  _buildCollaborator('Emma Davis', 'Caterer', 'https://via.placeholder.com/150'),
                  _buildCollaborator('John', 'Decx', 'https://via.placeholder.com/150'),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to see all collaborations
                },
                child: Text('See All'),
              ),
              SizedBox(height: 20),
              Text(
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey),
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
            backgroundImage: NetworkImage(imageUrl), // Load image from URL
          ),
          SizedBox(height: 8),
          Text(name),
          Text(role, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingOption(String title) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Handle setting option tap
      },
    );
  }
}