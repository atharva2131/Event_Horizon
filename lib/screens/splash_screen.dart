import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventhorizon/screens/RoleSelectionScreen.dart';
import 'package:eventhorizon/screens/user_dashboard.dart';
import 'package:eventhorizon/screens/vendor_dashboard.dart';
import 'package:eventhorizon/screens/admin_dashboard.dart';
import 'package:eventhorizon/screens/auth-service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Add a delay for splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null) {
      // User is logged in, check their role
      final userRole = await _authService.getUserRole();
      
      if (!mounted) return;
      
      if (userRole == 'admin') {
        // Navigate to admin dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else if (userRole == 'user') {
        // Navigate to user dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserDashboard()),
        );
      } else if (userRole == 'vendor') {
        // Navigate to vendor dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VendorDashboard()),
        );
      } else {
        // Invalid role or token, go to role selection
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        );
      }
    } else {
      // No token, go to role selection
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade500, Colors.deepPurple.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'EH',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'EventHorizon',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Plan your events with precision',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

