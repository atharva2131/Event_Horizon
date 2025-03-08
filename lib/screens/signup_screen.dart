import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isFormSubmitted = false; // Tracks if the user pressed submit
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // API URL - Replace with your actual API URL
  final String baseUrl = 'http://127.0.0.1:3000/api';

  Future<void> _submitForm() async {
    if (_formKey.currentState == null) {
      debugPrint("ERROR: Form key is null. Fixing...");
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "name": _nameController.text.trim(),
            "email": _emailController.text.trim(),
            "password": _passwordController.text,
            "phone": _phoneController.text.trim(),
            "role": "user"
          }),
        );
        
        final responseData = jsonDecode(response.body);
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          debugPrint("✅ Registration successful. Navigating to HomeScreen...");
          
          // Save user data if available
          if (responseData.containsKey('user')) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('userData', jsonEncode(responseData['user']));
          }
          
          // If the response includes tokens, save them
          if (responseData.containsKey('token')) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('token', responseData['token']);
          }
          
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          debugPrint("❌ Registration failed: ${response.body}");
          setState(() {
            if (responseData['errors'] != null && responseData['errors'] is List) {
              _errorMessage = responseData['errors'][0]['msg'] ?? 'Registration failed';
            } else {
              _errorMessage = responseData['msg'] ?? 'Registration failed';
            }
          });
        }
      } catch (e) {
        debugPrint("❌ Network error: ${e.toString()}");
        setState(() {
          _errorMessage = 'Network error: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      setState(() => _isFormSubmitted = true);
      debugPrint("❌ Form validation failed. Stay on SignupScreen.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Form(
                key: _formKey,
                autovalidateMode: _isFormSubmitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your full name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone (10 digits)',
                        border: OutlineInputBorder(),
                        hintText: '1234567890',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        // Exactly 10 digits as required by backend
                        final phoneRegex = RegExp(r'^\d{10}$');
                        if (!phoneRegex.hasMatch(value)) {
                          return 'Phone number must be exactly 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        helperText: 'Min 10 chars with uppercase, lowercase, number, and special char',
                        helperMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 10) {
                          return 'Password must be at least 10 characters long';
                        }
                        
                        // Match backend password requirements
                        final passwordRegex = RegExp(r'^(?=.[a-z])(?=.[A-Z])(?=.\d)(?=.[\W_])(?!.*\s).{10,}$');
                        if (!passwordRegex.hasMatch(value)) {
                          return 'Password must include uppercase, lowercase, number, and special character';
                        }
                        
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign Up'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}