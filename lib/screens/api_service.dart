import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/auth/users';

  // Helper method to get the auth token
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('adminToken');
  }

  // Helper method to create headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch all users
  static Future<List<dynamic>> fetchUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Toggle user status
  static Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
        body: jsonEncode({'isActive': !isActive}),
      );
      
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to update user status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Fetch all vendors
  static Future<List<dynamic>> fetchVendors() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/vendors'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load vendors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Fetch pending vendors
  static Future<List<dynamic>> fetchPendingVendors() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/vendors/pending'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load pending vendors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Toggle vendor status
  static Future<void> toggleVendorStatus(String vendorId, bool isActive) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/vendors/$vendorId'),
        headers: headers,
        body: jsonEncode({'isActive': !isActive}),
      );
      
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to update vendor status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Approve vendor
  static Future<void> approveVendor(String vendorId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/vendors/$vendorId/approve'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to approve vendor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Reject vendor
  static Future<void> rejectVendor(String vendorId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/vendors/$vendorId/reject'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to reject vendor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}