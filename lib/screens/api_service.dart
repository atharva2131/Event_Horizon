import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for API calls - change this to your actual backend URL
  static const String baseUrl = 'http://192.168.254.140:3000/api';
  
  // Get stored token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('adminToken');
  }
  
  // Handle API errors
  static String _handleError(dynamic error) {
    if (error is http.Response) {
      try {
        final errorData = jsonDecode(error.body);
        return errorData['msg'] ?? 'An error occurred';
      } catch (e) {
        return 'Server error: ${error.statusCode}';
      }
    }
    return error.toString();
  }
  
  // Create headers with authentication token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // AUTHENTICATION METHODS
  
  // Admin login
  static Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Check if user is admin
        if (data['user'] != null && data['user']['role'] == 'admin') {
          // Save token
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('adminToken', data['token']);
          prefs.setString('adminData', jsonEncode(data['user']));
          
          return {
            'success': true,
            'data': data,
          };
        } else {
          return {
            'success': false,
            'message': 'Unauthorized. Admin access required.',
          };
        }
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  // Admin logout
  static Future<bool> logout() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );
      
      // Clear stored tokens regardless of response
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('adminToken');
      prefs.remove('adminData');
      
      return response.statusCode == 200;
    } catch (e) {
      // Still clear tokens on error
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('adminToken');
      prefs.remove('adminData');
      
      return false;
    }
  }
  
  // USER MANAGEMENT METHODS
  
  // Fetch all users
  static Future<List<dynamic>> fetchUsers() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['users'] ?? [];
      } else {
        throw response;
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Fetch user by ID
  static Future<Map<String, dynamic>> fetchUserById(String userId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/$userId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user'] ?? {};
      } else {
        throw response;
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Fetch user bookings
  static Future<List<dynamic>> fetchUserBookings(String userId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/user/$userId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['bookings'] ?? [];
      } else {
        throw response;
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Update user admin notes
  static Future<bool> updateUserNotes(String userId, String notes) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/users/$userId/notes'),
        headers: headers,
        body: jsonEncode({
          'adminNotes': notes,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Toggle user status (active/inactive)
  static Future<bool> toggleUserStatus(String userId, bool isActive) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/users/$userId/status'),
        headers: headers,
        body: jsonEncode({
          'isActive': !isActive,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Delete user
  static Future<bool> deleteUser(String userId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/users/$userId'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Change user role
  static Future<bool> changeUserRole(String userId, String newRole) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/users/$userId/role'),
        headers: headers,
        body: jsonEncode({
          'role': newRole,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // VENDOR MANAGEMENT METHODS
  
  // Fetch all vendors
  static Future<List<dynamic>> fetchVendors() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/vendors'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['vendors'] ?? [];
      } else {
        throw response;
      }
    } catch (e) {
      throw _handleError(e);
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
        final data = jsonDecode(response.body);
        return data['vendors'] ?? [];
      } else {
        throw response;
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Fetch vendor by ID
  static Future<Map<String, dynamic>> fetchVendorById(String vendorId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/vendors/$vendorId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['vendor'] ?? {};
      } else {
        throw response;
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Toggle vendor status (active/inactive)
  static Future<bool> toggleVendorStatus(String vendorId, bool isActive) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/vendors/$vendorId/status'),
        headers: headers,
        body: jsonEncode({
          'isActive': !isActive,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Approve vendor
  static Future<bool> approveVendor(String vendorId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/vendors/$vendorId/approve'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Reject vendor
  static Future<bool> rejectVendor(String vendorId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/vendors/$vendorId/reject'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // DASHBOARD METHODS
  
  // Fetch dashboard data
  static Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['dashboardData'] ?? {};
      } else {
        throw response;
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // BOOKING METHODS
  
  // Fetch all bookings
  static Future<List<dynamic>> fetchBookings() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['bookings'] ?? [];
      } else {
        throw response;
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // PAYMENT METHODS
  
  // Fetch all payments
  static Future<List<dynamic>> fetchPayments() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/payments'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payments'] ?? [];
      } else {
        throw response;
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
}

