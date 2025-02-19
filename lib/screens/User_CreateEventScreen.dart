import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  String? _selectedEventType;
  final List<String> _eventTypes = ["Wedding", "Birthday", "Conference"];

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  // Function to select date
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

  // Function to select time
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  // Function to handle event creation
  void _createEvent() {
    if (_eventNameController.text.isEmpty || _selectedEventType == null || _dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields"), backgroundColor: Colors.red),
      );
      return;
    }

    // Create a new event object
    final newEvent = {
      'name': _eventNameController.text,
      'type': _selectedEventType!,
      'date': _dateController.text,
      'time': _timeController.text,
      'location': _locationController.text,
      'description': _descriptionController.text,
      'budget': _budgetController.text,
      'coverImage': _coverImage?.path ?? '', // Add cover image path if selected
    };

    // Pass the created event data back to the HomeScreen
    Navigator.pop(context, newEvent);

    // Optionally show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event created successfully!"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create Event", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _createEvent,
            child: const Text("Save", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Photo Upload
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  image: _coverImage != null
                      ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _coverImage == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.camera, color: Colors.grey, size: 30),
                            SizedBox(height: 8),
                            Text("Add Event Cover Photo", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Event Name
            _buildTextField("Event Name", "e.g., John & Sarah's Wedding", controller: _eventNameController),

            // Event Type Dropdown
            _buildDropdown(),

            // Date & Time Inputs
            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 10),
                Expanded(child: _buildTimePicker()),
              ],
            ),

            // Location Input
            _buildTextField("Location", "Search venue or address", controller: _locationController, icon: FontAwesomeIcons.mapMarkerAlt),

            // Description
            _buildTextField("Description", "Describe your event...", controller: _descriptionController, maxLines: 4),

            // Budget Input
            _buildTextField("Budget", "\$ 0.00", controller: _budgetController, keyboardType: TextInputType.number, icon: FontAwesomeIcons.dollarSign),

            // Create Event Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createEvent,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(14)),
                child: const Text("Create Event", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Text Input Field
  Widget _buildTextField(String label, String placeholder, {int maxLines = 1, TextInputType? keyboardType, IconData? icon, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: placeholder,
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Dropdown Field
  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Event Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButtonFormField(
          value: _selectedEventType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
          items: _eventTypes.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (value) {
            setState(() {
              _selectedEventType = value;
            });
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(child: _buildTextField("Date", "Select date", controller: _dateController, icon: FontAwesomeIcons.calendarAlt)),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: AbsorbPointer(child: _buildTextField("Time", "Select time", controller: _timeController, icon: FontAwesomeIcons.clock)),
    );
  }
}
