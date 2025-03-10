import 'dart:convert';
import 'package:eventhorizon/screens/user_dashboard.dart';
import 'package:eventhorizon/screens/vendor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  final bool isUser; // To differentiate User or Vendor

  const SignInPage({super.key, required this.isUser});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isSignIn = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Form keys for validation
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.  dispose();
    super.dispose();
  }

  // API URL - Replace with your actual API URL
  final String baseUrl = 'http://10.0.2.2:3000/api';

  // Sign In API Call
  Future<void> _signIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'role': widget.isUser ? 'user' : 'vendor'
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Save auth token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', responseData['token']);
        
        // Check if refreshToken is in cookies and save it if needed
        if (response.headers.containsKey('set-cookie')) {
          final cookies = response.headers['set-cookie'];
          if (cookies != null && cookies.contains('refreshToken=')) {
            final refreshToken = cookies.split('refreshToken=')[1].split(';')[0];
            prefs.setString('refreshToken', refreshToken);
          }
        }
        
        // Save user data if available
        if (responseData.containsKey('user')) {
          prefs.setString('userData', jsonEncode(responseData['user']));
        }

        // Navigate to appropriate dashboard
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget.isUser ? const UserDashboard() : const VendorDashboard(),
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

  // Sign Up API Call
  Future<void> _signUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'phone': _phoneController.text.trim(),
          'role': widget.isUser ? 'user' : 'vendor'
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registration successful
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please sign in.')),
        );
        
        // Switch to sign in tab
        setState(() => isSignIn = true);
      } else {
        // Handle error
        setState(() {
          if (responseData['errors'] != null && responseData['errors'] is List) {
            _errorMessage = responseData['errors'][0]['msg'] ?? 'Registration failed';
          } else {
            _errorMessage = responseData['msg'] ?? 'Registration failed';
          }
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
            colors: [Colors.deepPurple.shade500, Colors.blueAccent.shade200],
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
                    'EH',
                    style: GoogleFonts.poppins(
                      color: Colors.deepPurple,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'EventHorizon',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Plan your events with precision',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Tab Switcher
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      tabButton('Sign In', isSignIn, () => setState(() => isSignIn = true)),
                      tabButton('Sign Up', !isSignIn, () => setState(() => isSignIn = false)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

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

                // Animated Form
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isSignIn ? signInForm() : signUpForm(),
                ),

                const SizedBox(height: 20),
                dividerWithText(),

                // Social Login Buttons
                const SizedBox(height: 20),
                socialLoginButton(FontAwesomeIcons.google, 'Continue with Google', Colors.white, Colors.black),
                const SizedBox(height: 12),
                socialLoginButton(FontAwesomeIcons.apple, 'Continue with Apple', Colors.black, Colors.white),

                const SizedBox(height: 25),
                termsAndPrivacyText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Sign-In Form
  Widget signInForm() {
    return cardContainer(
      Form(
        key: _signInFormKey,
        child: Column(
          children: [
            textField('Email', Icons.email, controller: _emailController),
            const SizedBox(height: 16),
            textField('Password', Icons.lock, obscureText: true, controller: _passwordController),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {}, // Forgot password action
                child: const Text('Forgot Password?', style: TextStyle(color: Colors.deepPurple)),
              ),
            ),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.deepPurple)
                : actionButton('Sign In', _signIn),
          ],
        ),
      ),
    );
  }

  // Sign-Up Form
  Widget signUpForm() {
    return cardContainer(
      Form(
        key: _signUpFormKey,
        child: Column(
          children: [
            textField('Full Name', Icons.person, controller: _fullNameController),
            const SizedBox(height: 16),
            textField('Email', Icons.email, controller: _emailController),
            const SizedBox(height: 16),
            textField('Phone Number', Icons.phone, controller: _phoneController, isPhone: true),
            const SizedBox(height: 16),
            textField('Password', Icons.lock, obscureText: true, controller: _passwordController, isPassword: true),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.deepPurple)
                : actionButton('Sign Up', _signUp),
          ],
        ),
      ),
    );
  }

  // Custom Input Field
  Widget textField(String label, IconData icon, {
    bool obscureText = false, 
    TextEditingController? controller,
    bool isPassword = false,
    bool isPhone = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        helperText: isPassword 
            ? 'Min 10 chars with uppercase, lowercase, number, and special char'
            : null,
        helperMaxLines: 2,
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
        
        if (isPhone) {
          // Exactly 10 digits as required by backend
          final phoneRegex = RegExp(r'^\d{10}$');
          if (!phoneRegex.hasMatch(value)) {
            return 'Phone number must be exactly 10 digits';
          }
        }
        
        if (isPassword) {
          // Match backend password requirements
          if (value.length < 10) {
            return 'Password must be at least 10 characters long';
          }
          
          final passwordRegex = RegExp(r'^(?=.[a-z])(?=.[A-Z])(?=.\d)(?=.[\W_])(?!.*\s).{10,}$');
          if (!passwordRegex.hasMatch(value)) {
            return 'Password must include uppercase, lowercase, number, and special character';
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
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  // Social Login Buttons
  Widget socialLoginButton(IconData icon, String text, Color bgColor, Color textColor) {
    return SizedBox(
      width: 300,
      child: ElevatedButton.icon(
        onPressed: () {}, // Add login logic
        icon: Icon(icon, color: textColor),
        label: Text(text, style: GoogleFonts.poppins(fontSize: 16, color: textColor)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Tab Button
  Widget tabButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.deepPurple,
            ),
          ),
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

  // Divider with Text
  Widget dividerWithText() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('Or continue with', style: GoogleFonts.poppins(color: Colors.white70)),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }

  // Terms & Privacy Text
  Widget termsAndPrivacyText() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
    );
  }
}