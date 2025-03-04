import 'package:eventhorizon/screens/user_dashboard.dart';
import 'package:eventhorizon/screens/vendor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInPage extends StatefulWidget {
  final bool isUser; // To differentiate User or Vendor

  const SignInPage({super.key, required this.isUser});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Section
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurple,
                  child: const Text(
                    'EH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'EventHorizon',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Plan your events with precision',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Toggle Between Sign In & Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    tabButton('Sign In', isSignIn, () {
                      setState(() => isSignIn = true);
                    }),
                    const SizedBox(width: 20),
                    tabButton('Sign Up', !isSignIn, () {
                      setState(() => isSignIn = false);
                    }),
                  ],
                ),
                const SizedBox(height: 25),

                // Dynamic Form
                isSignIn ? signInForm() : signUpForm(),

                const SizedBox(height: 20),
                dividerWithText(),

                // Social Login Buttons
                const SizedBox(height: 20),
                socialLoginButton(FontAwesomeIcons.google, 'Continue with Google'),
                const SizedBox(height: 12),
                socialLoginButton(Icons.apple, 'Continue with Apple'),

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
    return Column(
      children: [
        textField('Email or Phone', Icons.email),
        const SizedBox(height: 16),
        textField('Password', Icons.lock, obscureText: true),
        const SizedBox(height: 16),
       Center(
  child: Padding(
    padding: const EdgeInsets.only(top: 10), // Adds spacing from the password field
    child: TextButton(
      onPressed: () {}, // Forgot password action
      child: const Text(
        'Forgot Password?',
        style: TextStyle(color: Colors.deepPurple, fontSize: 14),
      ),
    ),
  ),
),

        const SizedBox(height: 10),
        actionButton('Sign In', () {
          // Navigate to respective dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => widget.isUser ? UserDashboard() : VendorDashboard()),
          );
        }),
      ],
    );
  }

  // Sign-Up Form
  Widget signUpForm() {
    return Column(
      children: [
        textField('Full Name', Icons.person),
        const SizedBox(height: 16),
        textField('Email', Icons.email),
        const SizedBox(height: 16),
        textField('Phone Number', Icons.phone),
        const SizedBox(height: 16),
        textField('Password', Icons.lock, obscureText: true),
        const SizedBox(height: 20),
        actionButton('Sign Up', () {
          // Navigate to respective dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => widget.isUser ? UserDashboard() : VendorDashboard()),
          );
        }),
      ],
    );
  }
// Custom Styled Input Fields (Reduced width)
Widget textField(String label, IconData icon, {bool obscureText = false}) {
  return SizedBox(
    width: 350, // Set a fixed smaller width
    child: TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    ),
  );
}


  // Custom Button for Sign In & Sign Up (Reduced Width)
  Widget actionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200, // Reduced width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 14), // Same height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  // Social Media Login Buttons
  Widget socialLoginButton(IconData icon, String text) {
    return SizedBox(
       width: 300,
      child: ElevatedButton.icon(
        onPressed: () {}, // Add login logic
        icon: Icon(icon, color: Colors.black),
        label: Text(text, style: const TextStyle(fontSize: 16, color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Custom Tab Button for Sign In & Sign Up
  Widget tabButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.deepPurple : Colors.grey,
        ),
      ),
    );
  }

  // Divider with text
  Widget dividerWithText() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('Or continue with', style: TextStyle(color: Colors.grey)),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }

  // Terms and Privacy Text
  Widget termsAndPrivacyText() {
    return const Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey, fontSize: 12),
    );
  }
}
