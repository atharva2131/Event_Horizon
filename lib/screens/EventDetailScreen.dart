import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';


class EventDetailScreen extends StatefulWidget {
  final Map<String, String> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final List<String> allContacts = [
    "John Doe", "Jane Smith", "Alice Johnson", "Bob Brown", "Charlie Wilson"
  ];
  final Set<String> selectedContacts = {};

  late DateTime eventDateTime;
  int countdownEndTime = 0;

  final List<String> galleryImages = [
    "https://via.placeholder.com/400",
    "https://via.placeholder.com/400",
    "https://via.placeholder.com/400"
  ];

  @override
  void initState() {
    super.initState();
    _parseEventDateTime();
  }

  void _parseEventDateTime() {
    try {
      String dateTimeStr = "${widget.event['date']} ${widget.event['time']}";
      eventDateTime = DateFormat("d/M/yyyy h:mm a").parse(dateTimeStr);
      setState(() {
        countdownEndTime = eventDateTime.millisecondsSinceEpoch;
      });
    } catch (e) {
      debugPrint("Date format error: $e");
      eventDateTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          widget.event['name'] ?? 'Event Detail',
          style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _showContactList,
            tooltip: "Add Guest",
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareEvent,
            tooltip: "Share Event",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _displayEventImage(widget.event['image_url'] ?? ''),
            _buildEventDetails(),
            const SizedBox(height: 20),
            _buildCountdownTimer(),
            const SizedBox(height: 20),
            if (selectedContacts.isNotEmpty) ...[
              _buildSelectedContactsList(),
              _buildSendInvitationButton(),
            ],
            const SizedBox(height: 20),
            _buildGallerySection(),
          ],
        ),
      ),
    );
  }

  Widget _displayEventImage(String imageUrl) {
    return imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.network(
                "https://via.placeholder.com/400",
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              );
            },
          )
        : Image.file(
            File(imageUrl),
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          );
  }

  Widget _buildEventDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event['name'] ?? 'No Title',
            style: GoogleFonts.lato(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
              shadows: [
                const Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.purple),
              const SizedBox(width: 5),
              Text(widget.event['date'] ?? "Date not set", style: GoogleFonts.lato(fontSize: 16)),
              const SizedBox(width: 10),
              const Icon(Icons.access_time, color: Colors.blue),
              const SizedBox(width: 5),
              Text(widget.event['time'] ?? "Time not set", style: GoogleFonts.lato(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Center(
      child: CountdownTimer(
        endTime: countdownEndTime,
        textStyle: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  Widget _buildSelectedContactsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: selectedContacts.map((contact) {
          return ListTile(
            title: Text(contact, style: GoogleFonts.lato(fontSize: 16)),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                setState(() {
                  selectedContacts.remove(contact);
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSendInvitationButton() {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: _sendInvitations,
        icon: const Icon(Icons.send),
        label: const Text("Send Invitations"),
      ),
    );
  }

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Gallery",
            style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(galleryImages[index], width: 200, height: 150, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showContactList() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ListView(
              children: allContacts.map((contact) {
                return ListTile(
                  title: Text(contact),
                  trailing: Checkbox(
                    value: selectedContacts.contains(contact),
                    onChanged: (bool? isChecked) {
                      setModalState(() {
                        if (isChecked == true) {
                          selectedContacts.add(contact);
                        } else {
                          selectedContacts.remove(contact);
                        }
                      });
                      setState(() {}); // Update the main UI
                    },
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  void _sendInvitations() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Invitations sent to: ${selectedContacts.join(', ')}")),
    );
  }

  void _shareEvent() async {
    final eventText = """
You're invited to ${widget.event['name']}!

📅 Date: ${widget.event['date']}
⏰ Time: ${widget.event['time']}
📍 Location: ${widget.event['location'] ?? "Not specified"}
💬 Details: ${widget.event['details'] ?? ""}

👥 Guests: ${selectedContacts.isNotEmpty ? selectedContacts.join(', ') : "No guests added"}
""";

    await Share.share(eventText);
  }
}
