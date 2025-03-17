import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get Help & Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search for help',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Search logic
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            const Text('Quick Access', style: TextStyle(fontSize: 16)),
            ListTile(
              title: const Text('FAQ'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to FAQ
              },
            ),
            ListTile(
              title: const Text('Contact Support'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to contact support
              },
            ),
            ListTile(
              title: const Text('Live Chat'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to live chat
              },
            ),
          ],
        ),
      ),
    );
  }
}






