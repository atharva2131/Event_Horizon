import 'package:eventhorizon/screens/user_dashboard.dart';
import 'package:eventhorizon/screens/vendor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  final bool isUser ; // To differentiate User or Vendor

  const SignInPage({super.key, required this.isUser });

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isSignIn = true;

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
    _phoneController.dispose();
    super.dispose();
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
            textField('Email or Phone', Icons.email, controller: _emailController),
            const SizedBox(height: 16),
            textField('Password', Icons.lock, obscureText: true, controller: _passwordController),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {}, // Forgot password action
                child: const Text('Forgot Password?', style: TextStyle(color: Colors.deepPurple)),
              ),
            ),
            actionButton('Sign In', () {
              if (_signInFormKey.currentState!.validate()) {
                // Perform sign-in logic here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.isUser  ? UserDashboard() : VendorDashboard(),
                  ),
                );
              }
            }),
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
            textField('Phone Number', Icons.phone, controller: _phoneController),
            const SizedBox(height: 16),
            textField('Password', Icons.lock, obscureText: true, controller: _passwordController),
            const SizedBox(height: 20), // Added gap between Password and Sign Up button
            actionButton('Sign Up', () {
              if (_signUpFormKey.currentState!.validate()) {
                // Perform sign-up logic here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.isUser  ? UserDashboard() : VendorDashboard(),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  // Custom Input Field
  Widget textField(String label, IconData icon, {bool obscureText = false, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == 'Email' || label == 'Email or Phone') {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        if (label == 'Phone Number') {
          final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
          if (!phoneRegex.hasMatch(value)) {
            return 'Please enter a valid phone number';
          }
        }
        if (label == 'Password' && value.length < 6) {
          return 'Password must be at least 6 characters long';
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