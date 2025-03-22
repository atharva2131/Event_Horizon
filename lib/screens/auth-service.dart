import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.254.140:3000/api';
  
  // Check if the user is an admin
  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      return userData['role'] == 'admin';
    }
    
    return false;
  }
  
  // Get user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      return userData['role'];
    }
    
    return null;
  }
  
  // Login function that can be used from anywhere in the app
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String requestedRole,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': requestedRole,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Save auth token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', responseData['token']);
        
        // Save user data if available
        if (responseData.containsKey('user')) {
          prefs.setString('userData', jsonEncode(responseData['user']));
        }
        
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['msg'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  // Logout function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userData');
    await prefs.remove('refreshToken');
  }
}

