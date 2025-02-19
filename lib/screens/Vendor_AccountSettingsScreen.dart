import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AccountSettingsScreen extends StatefulWidget {
  final String name;
  final String email;
  final String profilePicture;

  const AccountSettingsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _email;
  File? _profilePicture;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _username = widget.name;
    _email = widget.email;
    _profilePicture = widget.profilePicture.isEmpty
        ? null
        : File(widget.profilePicture);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePicture = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _username = value!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _email = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Profile Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePicture == null
                        ? NetworkImage('https://via.placeholder.com/150')
                        : FileImage(_profilePicture!) as ImageProvider,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Return updated data to VendorProfileScreen
                      Navigator.pop(context, {
                        'name': _username,
                        'email': _email,
                        'profilePicture': _profilePicture?.path ?? '',
                      });
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
