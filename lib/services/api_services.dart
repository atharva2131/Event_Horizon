import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for your API - update this to your actual backend URL
  static const String baseUrl = 'http://192.168.254.140:3000/api';
  
  // Get the auth token from shared preferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Headers with authorization token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
  
  // Handle API errors and validate response
  static dynamic handleResponse(http.Response response) {
    // Check if response is HTML (error page) instead of JSON
    if (response.body.trim().startsWith('<')) {
      throw Exception('Server returned HTML instead of JSON. Status code: ${response.statusCode}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Only try to decode if there's content
      if (response.body.isNotEmpty) {
        try {
          return json.decode(response.body);
        } catch (e) {
          throw Exception('Failed to parse JSON response: $e');
        }
      }
      return null; // Empty response
    } else {
      // Try to parse error message from JSON if possible
      try {
        final errorData = json.decode(response.body);
        print('API Error Response: $errorData');
        
        // Extract error message with fallbacks
        String errorMessage = 'Unknown error';
        if (errorData['msg'] != null) {
          errorMessage = errorData['msg'];
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
        
        // Check for validation errors
        if (errorData['errors'] != null && errorData['errors'] is List && errorData['errors'].isNotEmpty) {
          final validationErrors = errorData['errors'];
          final firstError = validationErrors[0];
          if (firstError['msg'] != null) {
            errorMessage = firstError['msg'];
          }
        }
        
        throw Exception('API Error: $errorMessage');
      } catch (e) {
        if (e is Exception && e.toString().contains('API Error:')) {
          rethrow;
        }
        throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    }
  }
  
  // GET request
  static Future<dynamic> get(String endpoint) async {
    final headers = await getHeaders();
    try {
      print('GET Request: $baseUrl$endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      print('GET Response Status: ${response.statusCode}');
      return handleResponse(response);
    } catch (e) {
      print('GET Request Failed: $e');
      throw Exception('GET request failed: $e');
    }
  }
  
  // POST request
  static Future<dynamic> post(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    try {
      print('POST Request: $baseUrl$endpoint');
      print('POST Data: $data');
      
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      print('POST Response Status: ${response.statusCode}');
      print('POST Response Body: ${response.body}');
      
      return handleResponse(response);
    } catch (e) {
      print('POST Request Failed: $e');
      throw Exception('POST request failed: $e');
    }
  }
  
  // PUT request
  static Future<dynamic> put(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    try {
      print('PUT Request: $baseUrl$endpoint');
      print('PUT Data: $data');
      
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      print('PUT Response Status: ${response.statusCode}');
      return handleResponse(response);
    } catch (e) {
      print('PUT Request Failed: $e');
      throw Exception('PUT request failed: $e');
    }
  }
  
  // PATCH request
  static Future<dynamic> patch(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    try {
      print('PATCH Request: $baseUrl$endpoint');
      print('PATCH Data: $data');
      
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      print('PATCH Response Status: ${response.statusCode}');
      return handleResponse(response);
    } catch (e) {
      print('PATCH Request Failed: $e');
      throw Exception('PATCH request failed: $e');
    }
  }
  
  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    final headers = await getHeaders();
    try {
      print('DELETE Request: $baseUrl$endpoint');
      
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      
      print('DELETE Response Status: ${response.statusCode}');
      return handleResponse(response);
    } catch (e) {
      print('DELETE Request Failed: $e');
      throw Exception('DELETE request failed: $e');
    }
  }
}