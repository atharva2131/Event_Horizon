import 'package:flutter/material.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String profilePicture = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    profilePicture = widget.profilePicture;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    Navigator.pop(context, {
      'name': _nameController.text,
      'email': _emailController.text,
      'profilePicture': profilePicture,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 50, backgroundImage: NetworkImage(profilePicture)),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Implement image picker functionality here
                    },
                    child: const Text('Change Profile Picture'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Name', _nameController),
            _buildTextField('Email', _emailController),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
