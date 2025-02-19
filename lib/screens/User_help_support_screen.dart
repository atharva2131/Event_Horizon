import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faq = [
      {'question': 'How to book an event?', 'answer': 'Go to the events section and select your preferred event.'},
      {'question': 'How to contact support?', 'answer': 'You can email us at support@eventhorizon.com.'},
      {'question': 'How to cancel a booking?', 'answer': 'Go to "My Events" and choose "Cancel Booking".'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: faq.length,
          itemBuilder: (context, index) {
            return ExpansionTile(
              title: Text(faq[index]['question']!),
              children: [Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(faq[index]['answer']!),
              )],
            );
          },
        ),
      ),
    );
  }
}
