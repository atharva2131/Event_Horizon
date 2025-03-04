import 'package:flutter/material.dart';

class EventTimelineScreen extends StatefulWidget {
  const EventTimelineScreen({super.key});

  @override
  _EventTimelineScreenState createState() => _EventTimelineScreenState();
}

class _EventTimelineScreenState extends State<EventTimelineScreen> {
  final List<Map<String, dynamic>> _timelineItems = [
    {
      "time": "2:00 PM",
      "title": "Venue Setup Begins",
      "details": ["Setup team arrives", "Decoration setup starts", "Chair and table arrangement"]
    },
    {
      "time": "3:00 PM",
      "title": "Vendor Arrivals",
      "details": ["Photographer arrives", "Florist final touches", "Music setup begins"]
    },
    {
      "time": "3:30 PM",
      "title": "Wedding Party Arrives",
      "details": ["Bride & bridesmaids arrive", "Groom & groomsmen arrive", "Final preparations"]
    },
    {
      "time": "4:00 PM",
      "title": "Ceremony Begins",
      "details": ["Guest seating", "Processional", "Exchange of vows"]
    },
    {
      "time": "5:00 PM",
      "title": "Reception",
      "details": ["Cocktail hour", "Photo session", "Guest mingling"]
    },
    {
      "time": "6:00 PM",
      "title": "Main Events",
      "details": ["Grand entrance", "First dance", "Dinner service"]
    },
    {
      "time": "8:00 PM",
      "title": "Evening Activities",
      "details": ["Cake cutting", "Dance floor opens", "Evening celebrations"]
    },
  ];

  void _addTimelineItem() {
    TextEditingController timeController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    TextEditingController detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Timeline Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: "Time (e.g., 7:00 PM)"),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(labelText: "Details (comma-separated)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (timeController.text.isNotEmpty && titleController.text.isNotEmpty) {
                  setState(() {
                    _timelineItems.add({
                      "time": timeController.text,
                      "title": titleController.text,
                      "details": detailsController.text.split(',').map((e) => e.trim()).toList(),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text("Event Timeline", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // Implement edit functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _eventDetails(),
            const SizedBox(height: 20),
            Expanded(child: _timelineList()),
            _addTimelineButton(context),
          ],
        ),
      ),
    );
  }

  // Event Details Card
  Widget _eventDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Beach Wedding", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.access_time, color: Colors.grey),
              SizedBox(width: 8),
              Text("Saturday, August 12, 2023", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.grey),
              SizedBox(width: 8),
              Text("Malibu Beach", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // Timeline List
  Widget _timelineList() {
    return ListView.builder(
      itemCount: _timelineItems.length,
      itemBuilder: (context, index) {
        final item = _timelineItems[index];
        return _timelineItem(item["time"], item["title"], item["details"]);
      },
    );
  }

  // Timeline Item Widget
  Widget _timelineItem(String time, String title, List<String> details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 10, bottom: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: details.map((detail) => Text("• $detail", style: const TextStyle(color: Colors.grey))).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Add Timeline Item Button
  Widget _addTimelineButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: _addTimelineItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Timeline Item", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
