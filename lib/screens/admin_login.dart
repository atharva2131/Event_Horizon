import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // API URL - Replace with your actual API URL
  final String baseUrl = 'http://192.168.254.140:3000/api';

  // Admin Sign In API Call
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Save auth token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('adminToken', responseData['token']);
        
        // Save admin data if available
        if (responseData.containsKey('admin')) {
          prefs.setString('adminData', jsonEncode(responseData['admin']));
        }

        // Navigate to admin dashboard
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
      } else {
        // Handle error
        setState(() {
          _errorMessage = responseData['msg'] ?? 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    'A',
                    style: GoogleFonts.poppins(
                      color: Colors.deepPurple.shade800,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'EventHorizon Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Manage your platform with ease',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Error message if any
                if (_errorMessage != null)
                  Container(
                    width: 350,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        color: Colors.red.shade800,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Admin Login Form
                cardContainer(
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        textField('Email', Icons.email, controller: _emailController),
                        const SizedBox(height: 16),
                        textField('Password', Icons.lock, obscureText: true, controller: _passwordController),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {}, // Forgot password action
                            child: Text(
                              'Forgot Password?', 
                              style: TextStyle(color: Colors.deepPurple.shade700),
                            ),
                          ),
                        ),
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.deepPurple.shade700)
                            : actionButton('Sign In', _signIn),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                
                Text(
                  'Admin access is restricted to authorized personnel only',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom Input Field
  Widget textField(String label, IconData icon, {
    bool obscureText = false, 
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        
        if (label == 'Email') {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        
        return null;
      },
    );
  }

  // Action Button
  Widget actionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text, 
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  // Card Container for Forms
  Widget cardContainer(Widget child) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: child,
    );
  }
}

