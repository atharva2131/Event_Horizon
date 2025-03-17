import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard.dart';

class AdminAuthCheck {
  // Check if the user has admin role and redirect if needed
  static Future<bool> checkAndRedirect(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');
      
      if (userData != null) {
        final user = jsonDecode(userData);
        
        // Check if user has admin role
        if (user['role'] == 'admin') {
          // Ensure we have admin token
          final token = prefs.getString('token');
          if (token != null) {
            prefs.setString('adminToken', token);
            prefs.setString('adminData', userData);
            
            // Navigate to admin dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Error checking admin auth: $e');
      return false;
    }
  }
}

