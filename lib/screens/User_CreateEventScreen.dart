// lib/screens/User_CreateEventScreen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/event_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  File? _coverImage;
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _guestController = TextEditingController();
  final _newGuestNameController = TextEditingController();
  final _newGuestEmailController = TextEditingController();
  final _newGuestPhoneController = TextEditingController();
  String? _selectedEventType;
  final List<String> _eventTypes = [
    "Wedding",
    "Birthday",
    "Corporate",
    "Holiday",
    "Anniversary",
    "Graduation",
    "Baby Shower",
    "Retirement",
    "Other",
  ];
  final List<Map<String, dynamic>> _guestList = [];
  List<Contact> _contacts = [];
  bool _isLoadingContacts = false;
  bool _isCreatingEvent = false;

  final EventService _eventService = EventService();

  static const Color primaryColor = Colors.deepPurple;
  static const Color lightPurple = Color(0xffd1c4e9);
  static const Color backgroundColor = Colors.white;
  static const Color textOnPurple = Colors.white;
  static const Color textOnWhite = Color(0xff311b92);

  @override
  void initState() {
    super.initState();
    _requestContactPermission();
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        // Format the time as "HH:mm" (24-hour format)
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute";
      });
    }
  }

  void _addGuest() {
    if (_guestController.text.isNotEmpty) {
      setState(() {
        _guestList.add({
          'name': _guestController.text,
          'email': '',
          'phone': '',
          'status': 'Not Invited'
        });
        _guestController.clear();
      });
    }
  }

  void _showContactsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
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
                      const Text(
                        "Select Contacts",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddNewGuestDialog();
                            },
                            icon: const Icon(Icons.person_add,
                                color: primaryColor),
                            label: const Text("New",
                                style: TextStyle(color: primaryColor)),
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
                              final email = contact.emails.isNotEmpty == true
                                  ? contact.emails.first.address ?? ""
                                  : "";
                              final phone = contact.phones.isNotEmpty == true
                                  ? contact.phones.first.number ?? ""
                                  : "";

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: primaryColor,
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(name),
                                subtitle: Text(email.isNotEmpty
                                    ? email
                                    : (phone.isNotEmpty
                                        ? phone
                                        : "No contact info")),
                                onTap: () {
                                  setState(() {
                                    _guestList.add({
                                      'name': name,
                                      'email': email,
                                      'phone': phone,
                                      'status': 'Not Invited'
                                    });
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("$name added to guest list"),
                                      backgroundColor: Colors.green.shade400,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        ),
    );
  }

  void _showAddNewGuestDialog() {
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
                  setState(() {
                    _guestList.add({
                      'name': _newGuestNameController.text,
                      'email': _newGuestEmailController.text,
                      'phone': _newGuestPhoneController.text,
                      'status': 'Not Invited'
                    });
                  });
                  _newGuestNameController.clear();
                  _newGuestEmailController.clear();
                  _newGuestPhoneController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("New guest added to list"),
                      backgroundColor: Colors.green.shade400,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Guest name is required"),
                      backgroundColor: Colors.red.shade400,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEvent() async {
    if (
      _eventNameController.text.isEmpty ||
      _selectedEventType == null ||
      _dateController.text.isEmpty ||
      _timeController.text.isEmpty ||
      _locationController.text.isEmpty
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all required fields"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isCreatingEvent = true;
    });

    try {
      // Parse date
      List<String> dateParts = _dateController.text.split("/");
      if (dateParts.length != 3) {
        throw FormatException("Invalid date format. Expected dd/MM/yyyy");
      }

      // Fix the time string if it contains a dot (.)
      String timeText = _timeController.text.replaceAll(".", ":");

      // Parse time
      List<String> timeParts = timeText.split(":");
      if (timeParts.length != 2) {
        throw FormatException("Invalid time format. Expected HH:mm");
      }

      // Format date for API
      String formattedDate = "${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}"; // YYYY-MM-DD

      // Format guests properly
      List<Map<String, dynamic>> formattedGuests = _guestList
        .map((guest) => {
          "name": guest['name'] ?? '',
          'email': guest['email'] ?? '',
          'phone': guest['phone'] ?? '',
          'rsvpStatus': 'pending',
          'inviteSent': false,
          'source': 'manual',
        })
        .toList();

      // Parse budget safely
      double? budget;
      if (_budgetController.text.isNotEmpty) {
        budget = double.tryParse(_budgetController.text);
      }

      // Create event data with separate eventTime field
      Map<String, dynamic> eventData = {
        'eventName': _eventNameController.text,
        'eventDate': formattedDate,
        'eventTime': "${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}", // HH:MM
        'location': _locationController.text,
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : "",
        'budget': budget ?? 0,
        'category': _selectedEventType,
        'isPublic': false,
        'status': "planning",
        'guests': formattedGuests,
      };

      // Print the data being sent
      print("Sending event data: $eventData");

      // Create event on the server
      final createdEvent = await _eventService.createEvent(eventData);

      // Upload image if selected
      String? imageUrl;
      if (_coverImage != null && createdEvent["_id"] != null) {
        try {
          // Verify the image file exists and has content
          if ((await _coverImage!.exists()) && (await _coverImage!.length()) > 0) {
            print("Uploading image for event: ${createdEvent['_id']}");

            // Try to upload the image
            imageUrl = await _eventService.uploadEventImage(createdEvent["_id"], _coverImage!);
            print("Image uploaded successfully: $imageUrl");

            // Update event with image URL if upload was successful
            if (imageUrl.isNotEmpty) {
              await _eventService.updateEvent(createdEvent["_id"], {
                'eventImage': imageUrl,
              });
              print("Event updated with image URL: $imageUrl");
            }
          } else {
            print("Image file is invalid or empty");
          }
        } catch (e) {
          print("Error uploading image: $e");
          // Continue with event creation even if image upload fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Event created but image upload failed: $e"),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // Format the event for the app
      final newEvent = {
        'id': createdEvent["_id"],
        'name': _eventNameController.text,
        'type': _selectedEventType!,
        'date': _dateController.text,
        'time': _timeController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'budget': _budgetController.text,
        'eventImage': imageUrl ?? "",
        'guests': _guestList,
      };

      setState(() {
        _isCreatingEvent = false;
      });

      Navigator.pop(context, newEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Event created successfully!"),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() {
        _isCreatingEvent = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating event: $e"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textOnPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create Event", style: TextStyle(color: textOnPurple)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isCreatingEvent ? null : _createEvent,
            child: _isCreatingEvent 
              ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
              : const Text("Save",
                  style: TextStyle(
                      color: textOnPurple, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverPhotoUpload(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField("Event Name", "e.g., John & Sarah's Wedding",
                      controller: _eventNameController,
                      icon: FontAwesomeIcons.star),
                  _buildDropdown(),
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTimePicker()),
                    ],
                  ),
                  _buildTextField("Location", "Search venue or address",
                      controller: _locationController,
                      icon: FontAwesomeIcons.mapMarkerAlt),
                  _buildTextField("Description", "Describe your event...",
                      controller: _descriptionController,
                      maxLines: 4,
                      icon: FontAwesomeIcons.alignLeft),
                  _buildTextField("Budget", "\$ 0.00",
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      icon: FontAwesomeIcons.dollarSign),
                  _buildGuestSection(),
                  const SizedBox(height: 24),
                  _buildCreateEventButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Guest List",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textOnWhite)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _guestController,
                  decoration: InputDecoration(
                    hintText: "Enter guest email or name",
                    prefixIcon:
                        const Icon(FontAwesomeIcons.user, color: primaryColor),
                    filled: true,
                    fillColor: lightPurple.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addGuest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 236, 231, 245),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Add"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _showContactsBottomSheet,
                icon: const Icon(Icons.contacts),
                label: const Text("Add from Contacts"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 236, 231, 245),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _showAddNewGuestDialog,
                icon: const Icon(Icons.person_add),
                label: const Text("New Contact"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 236, 231, 245),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _guestList.isNotEmpty
              ? Column(
                  children: _guestList
                      .map((guest) => _buildGuestListItem(guest))
                      .toList(),
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No guests added yet",
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildGuestListItem(Map<String, dynamic> guest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: lightPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor,
            radius: 20,
            child: Text(
              guest['name']!.isNotEmpty ? guest['name']![0].toUpperCase() : "?",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest['name'] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (guest['email']!.isNotEmpty)
                  Text(
                    guest['email'] ?? "",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                if (guest['phone']!.isNotEmpty)
                  Text(
                    guest['phone'] ?? "",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () => setState(() {
                _guestList.remove(guest);
              }),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateEventButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreatingEvent ? null : _createEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPurple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isCreatingEvent
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text("Create Event",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCoverPhotoUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        color: lightPurple.withOpacity(0.3),
        child: _coverImage != null
            ? Image.file(_coverImage!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(FontAwesomeIcons.image, size: 40, color: primaryColor),
                  SizedBox(height: 8),
                  Text("Add Cover Photo",
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      {TextEditingController? controller,
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textOnWhite)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
              filled: true,
              fillColor: lightPurple.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Event Type",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textOnWhite)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: lightPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Select event type"),
                value: _selectedEventType,
                icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
                items: _eventTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedEventType = newValue;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: _buildTextField(
          "Date",
          "Select date",
          controller: _dateController,
          icon: FontAwesomeIcons.calendar,
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: AbsorbPointer(
        child: _buildTextField(
          "Time",
          "Select time",
          controller: _timeController,
          icon: FontAwesomeIcons.clock,
        ),
      ),
    );
  }
}