import 'package:flutter/material.dart';

class PrivacyTermsScreen extends StatelessWidget {
  const PrivacyTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Terms')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We value your privacy and will never share your personal data without your consent. Your information is protected under our strict data policies.',
            ),
            SizedBox(height: 20),
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'By using our services, you agree to abide by our terms and conditions. Misuse of the platform may result in account suspension.',
            ),
          ],
        ),
      ),
    );
  }
}
