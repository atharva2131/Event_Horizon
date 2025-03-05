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

  // Define theme colors
  static const Color primaryColor = Colors.deepPurple;
  static const Color lightPurple = Color(0xFFD1C4E9); // Deep Purple 100
  static const Color backgroundColor = Colors.white;
  static const Color textOnPurple = Colors.white;
  static const Color textOnWhite = Color(0xFF311B92); // Deep Purple 900

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(primary: primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(primary: primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _createEvent() {
    if (_eventNameController.text.isEmpty ||
        _selectedEventType == null ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
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

    final newEvent = {
      'name': _eventNameController.text,
      'type': _selectedEventType!,
      'date': _dateController.text,
      'time': _timeController.text,
      'location': _locationController.text,
      'description': _descriptionController.text,
      'budget': _budgetController.text,
      'image_url': _coverImage?.path ?? '',
    };

    Navigator.pop(context, newEvent);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Event created successfully!"),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
            onPressed: _createEvent,
            child: const Text("Save",
                style: TextStyle(color: textOnPurple, fontWeight: FontWeight.bold)),
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
                      controller: _eventNameController, icon: FontAwesomeIcons.star),
                  _buildDropdown(),
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTimePicker()),
                    ],
                  ),
                  _buildTextField("Location", "Search venue or address",
                      controller: _locationController, icon: FontAwesomeIcons.mapMarkerAlt),
                  _buildTextField("Description", "Describe your event...",
                      controller: _descriptionController, maxLines: 4, icon: FontAwesomeIcons.alignLeft),
                  _buildTextField("Budget", "\$ 0.00",
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      icon: FontAwesomeIcons.dollarSign),
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

  Widget _buildCoverPhotoUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: lightPurple,
          image: _coverImage != null
              ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover)
              : null,
        ),
        child: _coverImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(FontAwesomeIcons.camera, color: primaryColor, size: 40),
                  SizedBox(height: 12),
                  Text("Add Event Cover Photo",
                      style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder,
      {int maxLines = 1,
      TextInputType? keyboardType,
      IconData? icon,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textOnWhite)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
              filled: true,
              fillColor: lightPurple.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textOnWhite)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: lightPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEventType,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
                items: _eventTypes.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item, style: const TextStyle(color: textOnWhite)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
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
        child: _buildTextField("Date", "Select date",
            controller: _dateController, icon: FontAwesomeIcons.calendarAlt),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: AbsorbPointer(
        child: _buildTextField("Time", "Select time",
            controller: _timeController, icon: FontAwesomeIcons.clock),
      ),
    );
  }

  Widget _buildCreateEventButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPurple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Create Event", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

