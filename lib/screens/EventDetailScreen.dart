import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  List<Contact> _contacts = [];
  bool _isLoadingContacts = false;
  final TextEditingController _newGuestNameController = TextEditingController();
  final TextEditingController _newGuestEmailController =
      TextEditingController();
  final TextEditingController _newGuestPhoneController =
      TextEditingController();
  final TextEditingController _invitationMessageController =
      TextEditingController();

  late DateTime eventDateTime;
  int countdownEndTime = 0;

  final List<String> galleryImages = [
    "https://via.placeholder.com/400",
    "https://via.placeholder.com/400",
    "https://via.placeholder.com/400"
  ];

  // Deep purple color palette
  final Color primaryPurple = const Color(0xFF4A148C); // Deep Purple 900
  final Color lightPurple = const Color(0xFF7C43BD); // Lighter purple
  final Color accentPurple = const Color(0xFF9C27B0); // Purple 500
  final Color backgroundPurple = const Color(0xFFF5F0FF); // Very light purple

  @override
  void initState() {
    super.initState();
    _parseEventDateTime();
    _requestContactPermission();

    // Initialize invitation message
    _invitationMessageController.text =
        "You're invited to ${widget.event['name']}!\n\nJoin us on ${widget.event['date']} at ${widget.event['time']}.\n\nLocation: ${widget.event['location'] ?? 'TBD'}\n\nPlease RSVP by clicking the link below.";
  }

  void _updateEventAndReturn() {
    // This will pass the updated event back to the home screen
    Navigator.pop(context, widget.event);
  }

  Future<void> _requestContactPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      _loadContacts();
    }
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoadingContacts = true;
    });

    try {
      final contacts = await FlutterContacts.getContacts();
      setState(() {
        _contacts = contacts.toList();
        _isLoadingContacts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingContacts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load contacts: $e"),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
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

  void _shareEvent() async {
    final eventText = """
You're invited to ${widget.event['name']}!

📅 Date: ${widget.event['date']}
⏰ Time: ${widget.event['time']}
📍 Location: ${widget.event['location'] ?? "Not specified"}
💬 Details: ${widget.event['description'] ?? ""}

Please RSVP soon!
""";

    await Share.share(eventText);
  }

  void _showContactList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Guests",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddNewGuestDialog();
                            },
                            icon: Icon(Icons.person_add, color: accentPurple),
                            label: Text(
                              "New",
                              style: GoogleFonts.poppins(color: accentPurple),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search contacts...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryPurple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _isLoadingContacts
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _contacts.length,
                            itemBuilder: (context, index) {
                              final contact = _contacts[index];
                              final name = contact.displayName ?? "No Name";
                              final email = contact.emails?.isNotEmpty == true
                                  ? contact.emails!.first.address ?? ""
                                  : "";
                              final phone = contact.phones?.isNotEmpty == true
                                  ? contact.phones!.first.number ?? ""
                                  : "";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: lightPurple,
                                    child: Text(
                                      name.isNotEmpty
                                          ? name.substring(0, 1).toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(name),
                                  subtitle: Text(
                                    email.isNotEmpty
                                        ? email
                                        : (phone.isNotEmpty
                                            ? phone
                                            : "No contact info"),
                                  ),
                                  onTap: () {
                                    List<Map<String, dynamic>> guestList = [];
                                    if (widget.event['guests'] != null) {
                                      guestList =
                                          List<Map<String, dynamic>>.from(
                                              widget.event['guests']);
                                    }

                                    // Check if contact already exists in guest list
                                    bool exists = guestList.any((g) =>
                                        (g['email'] == email &&
                                            email.isNotEmpty) ||
                                        (g['phone'] == phone &&
                                            phone.isNotEmpty));

                                    if (!exists) {
                                      setState(() {
                                        guestList.add({
                                          'name': name,
                                          'email': email,
                                          'phone': phone,
                                          'status': 'Not Invited'
                                        });
                                        widget.event['guests'] = guestList;
                                      });

                                      _updateEventAndReturn();

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("$name added to guest list"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "$name is already in the guest list"),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddNewGuestDialog() {
    _newGuestNameController.clear();
    _newGuestEmailController.clear();
    _newGuestPhoneController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Guest"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newGuestNameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newGuestEmailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newGuestPhoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone",
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newGuestNameController.text.isNotEmpty) {
                  List<Map<String, dynamic>> guestList = [];
                  if (widget.event['guests'] != null) {
                    guestList =
                        List<Map<String, dynamic>>.from(widget.event['guests']);
                  }

                  setState(() {
                    guestList.add({
                      'name': _newGuestNameController.text,
                      'email': _newGuestEmailController.text,
                      'phone': _newGuestPhoneController.text,
                      'status': 'Not Invited'
                    });
                    widget.event['guests'] = guestList;
                  });

                  _updateEventAndReturn();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("New guest added to list"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Guest name is required"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showEditGuestDialog(Map<String, dynamic> guest) {
    _newGuestNameController.text = guest['name'] ?? '';
    _newGuestEmailController.text = guest['email'] ?? '';
    _newGuestPhoneController.text = guest['phone'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Guest"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newGuestNameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newGuestEmailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newGuestPhoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone",
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newGuestNameController.text.isNotEmpty) {
                  setState(() {
                    guest['name'] = _newGuestNameController.text;
                    guest['email'] = _newGuestEmailController.text;
                    guest['phone'] = _newGuestPhoneController.text;
                  });
                  Navigator.pop(context);
                  _updateEventAndReturn();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showChangeStatusDialog(Map<String, dynamic> guest) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update RSVP Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Not Invited"),
                leading: Radio<String>(
                  value: "Not Invited",
                  groupValue: guest['status'],
                  onChanged: (value) {
                    setState(() {
                      guest['status'] = value;
                    });
                    Navigator.pop(context);
                    _updateEventAndReturn();
                  },
                ),
              ),
              ListTile(
                title: const Text("Invited"),
                leading: Radio<String>(
                  value: "Invited",
                  groupValue: guest['status'],
                  onChanged: (value) {
                    setState(() {
                      guest['status'] = value;
                    });
                    Navigator.pop(context);
                    _updateEventAndReturn();
                  },
                ),
              ),
              ListTile(
                title: const Text("Confirmed"),
                leading: Radio<String>(
                  value: "Confirmed",
                  groupValue: guest['status'],
                  onChanged: (value) {
                    setState(() {
                      guest['status'] = value;
                    });
                    Navigator.pop(context);
                    _updateEventAndReturn();
                  },
                ),
              ),
              ListTile(
                title: const Text("Maybe"),
                leading: Radio<String>(
                  value: "Maybe",
                  groupValue: guest['status'],
                  onChanged: (value) {
                    setState(() {
                      guest['status'] = value;
                    });
                    Navigator.pop(context);
                    _updateEventAndReturn();
                  },
                ),
              ),
              ListTile(
                title: const Text("Declined"),
                leading: Radio<String>(
                  value: "Declined",
                  groupValue: guest['status'],
                  onChanged: (value) {
                    setState(() {
                      guest['status'] = value;
                    });
                    Navigator.pop(context);
                    _updateEventAndReturn();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteGuest(Map<String, dynamic> guest) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Guest"),
          content: Text(
              "Are you sure you want to remove ${guest['name']} from the guest list?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  List<Map<String, dynamic>> guestList =
                      List<Map<String, dynamic>>.from(widget.event['guests']);
                  guestList.remove(guest);
                  widget.event['guests'] = guestList;
                });
                Navigator.pop(context);
                _updateEventAndReturn();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _inviteGuest(Map<String, dynamic> guest) {
    String email = guest['email'] ?? '';
    String phone = guest['phone'] ?? '';

    if (email.isEmpty && phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No contact information available for this guest"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Send Invitation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Send invitation to ${guest['name']}"),
              const SizedBox(height: 10),
              if (email.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    _sendEmailInvitation(guest);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.email),
                  label: const Text("Send Email"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                  ),
                ),
              const SizedBox(height: 10),
              if (phone.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    _sendSMSInvitation(guest);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.sms),
                  label: const Text("Send SMS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentPurple,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmailInvitation(Map<String, dynamic> guest) async {
    String email = guest['email'] ?? '';
    if (email.isEmpty) return;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Invitation to ${widget.event['name']}&body=${Uri.encodeComponent(_invitationMessageController.text)}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        setState(() {
          guest['status'] = 'Invited';
        });
        _updateEventAndReturn();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch email app")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _sendSMSInvitation(Map<String, dynamic> guest) async {
    String phone = guest['phone'] ?? '';
    if (phone.isEmpty) return;

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': _invitationMessageController.text},
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        setState(() {
          guest['status'] = 'Invited';
        });
        _updateEventAndReturn();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch SMS app")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showInvitationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Customize Invitation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _invitationMessageController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: "Invitation Message",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose invitation design:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildInvitationTemplate("Classic", Colors.blue[100]!),
                    _buildInvitationTemplate("Elegant", Colors.purple[100]!),
                    _buildInvitationTemplate("Modern", Colors.green[100]!),
                  ],
                ),
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
                Navigator.pop(context);
                _sendInvitationsToAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
              ),
              child: const Text("Send to All"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvitationTemplate(String name, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(name),
        ],
      ),
    );
  }

  void _sendInvitationsToAll() {
    List<Map<String, dynamic>> guestList =
        List<Map<String, dynamic>>.from(widget.event['guests']);
    int emailCount = 0;
    int smsCount = 0;

    for (var guest in guestList) {
      if (guest['status'] == 'Not Invited') {
        if (guest['email'] != null && guest['email'].isNotEmpty) {
          emailCount++;
        } else if (guest['phone'] != null && guest['phone'].isNotEmpty) {
          smsCount++;
        }

        guest['status'] = 'Invited';
      }
    }

    setState(() {
      widget.event['guests'] = guestList;
    });

    _updateEventAndReturn();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Invitations prepared: $emailCount emails, $smsCount SMS"),
        backgroundColor: primaryPurple,
        action: SnackBarAction(
          label: "SEND NOW",
          onPressed: () {
            // In a real app, this would trigger actual sending
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invitations sent successfully!")),
            );
          },
          textColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGallerySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 15),
            child: Row(
              children: [
                Icon(Icons.photo_library, color: primaryPurple),
                const SizedBox(width: 10),
                Text(
                  "Gallery",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 15),
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      galleryImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 80), // Extra space for FAB
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventDetails(),
                _buildCountdownTimer(),
                const SizedBox(height: 20),
                _buildLocationSection(),
                const SizedBox(height: 20),
                _buildGuestsSection(),
                const SizedBox(height: 20),
                _buildGallerySection(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareEvent,
        backgroundColor: primaryPurple,
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text("Share Event", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: primaryPurple,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.event['name'] ?? 'Event Detail',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            _displayEventImage(widget.event['image_url'] ?? ''),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.group_add, color: Colors.white),
          onPressed: _showContactList,
          tooltip: "Add Guest",
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Added to calendar")),
            );
          },
          tooltip: "Add to Calendar",
        ),
      ],
    );
  }

  Widget _displayEventImage(String imageUrl) {
    return imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.network(
                "https://via.placeholder.com/400",
                fit: BoxFit.cover,
              );
            },
          )
        : Image.file(
            File(imageUrl),
            fit: BoxFit.cover,
          );
  }

  Widget _buildEventDetails() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event['name'] ?? 'No Title',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.calendar_today,
                widget.event['date'] ?? "Date not set",
                primaryPurple,
              ),
              const SizedBox(width: 10),
              _buildInfoChip(
                Icons.access_time,
                widget.event['time'] ?? "Time not set",
                accentPurple,
              ),
            ],
          ),
          if (widget.event['description'] != null &&
              widget.event['description']!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              "About",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.event['description'] ?? "",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer() {
    final now = DateTime.now();
    final difference = eventDateTime.difference(now);
    final isEventPassed = difference.isNegative;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: primaryPurple,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isEventPassed ? "Event has ended" : "Event starts in",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 10),
          isEventPassed
              ? Text(
                  "Event has already taken place",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : CountdownTimer(
                  endTime: countdownEndTime,
                  widgetBuilder: (_, time) {
                    if (time == null) {
                      return Text(
                        "Event has started!",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCountdownUnit(time.days ?? 0, "Days"),
                        _buildCountdownUnit(time.hours ?? 0, "Hours"),
                        _buildCountdownUnit(time.min ?? 0, "Minutes"),
                        _buildCountdownUnit(time.sec ?? 0, "Seconds"),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCountdownUnit(int value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: primaryPurple),
              const SizedBox(width: 10),
              Text(
                "Location",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.event['location'] ?? "Location not specified",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.map,
                  size: 50,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Opening maps...")),
              );
            },
            icon: const Icon(Icons.directions),
            label: const Text("Get Directions"),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestsSection() {
    List<Map<String, dynamic>> guestList = [];
    if (widget.event['guests'] != null) {
      guestList = List<Map<String, dynamic>>.from(widget.event['guests']);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people, color: primaryPurple),
                  const SizedBox(width: 10),
                  Text(
                    "Guests",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _showContactList,
                    icon: Icon(Icons.add, color: accentPurple, size: 18),
                    label: Text(
                      "Add",
                      style: GoogleFonts.poppins(
                        color: accentPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (guestList.isNotEmpty)
                    TextButton.icon(
                      onPressed: _showInvitationDialog,
                      icon: Icon(Icons.send, color: primaryPurple, size: 18),
                      label: Text(
                        "Invite",
                        style: GoogleFonts.poppins(
                          color: primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          guestList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No guests added yet",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    ...guestList
                        .map((guest) => _buildGuestItem(guest))
                        .toList(),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total: ${guestList.length} guests",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryPurple,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "RSVP Status: ",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${guestList.where((g) => g['status'] == 'Confirmed').length} Confirmed",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildGuestItem(Map<String, dynamic> guest) {
    String name = guest['name'] ?? "";
    String email = guest['email'] ?? "";
    String phone = guest['phone'] ?? "";
    String status = guest['status'] ?? "Not Invited";

    Color statusColor;
    switch (status) {
      case 'Confirmed':
        statusColor = Colors.green;
        break;
      case 'Declined':
        statusColor = Colors.red;
        break;
      case 'Maybe':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundPurple,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: lightPurple,
            radius: 20,
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditGuestDialog(guest);
              } else if (value == 'delete') {
                _deleteGuest(guest);
              } else if (value == 'invite') {
                _inviteGuest(guest);
              } else if (value == 'status') {
                _showChangeStatusDialog(guest);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Row(
                  children: [
                    Icon(Icons.update, size: 18),
                    SizedBox(width: 8),
                    Text('Change Status'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'invite',
                child: Row(
                  children: [
                    Icon(Icons.send, size: 18),
                    SizedBox(width: 8),
                    Text('Send Invitation'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
