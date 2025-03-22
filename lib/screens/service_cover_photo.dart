import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

// This class handles service cover photo functionality
class ServiceCoverPhotoManager {
  final String baseApiUrl;
  final Color primaryColor;
  final ImagePicker _picker = ImagePicker();
  
  ServiceCoverPhotoManager({
    required this.baseApiUrl,
    required this.primaryColor,
  });

  // Pick and upload a cover photo for a service
  Future<Map<String, dynamic>?> pickAndUploadCoverPhoto(
    BuildContext context,
    String serviceId,
    String serviceName,
  ) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image == null) return null;
    
    final File imageFile = File(image.path);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(height: 16),
              const Text("Uploading cover photo..."),
            ],
          ),
        );
      },
    );
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return null;
      }
      
      // Create multipart request for file upload
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseApiUrl/vendors/services/$serviceId/cover'),
      );
      
      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      // Determine file type
      final ext = path.extension(imageFile.path).toLowerCase();
      final contentType = ext == '.jpg' || ext == '.jpeg' 
          ? 'image/jpeg' 
          : ext == '.png' 
              ? 'image/png' 
              : ext == '.gif' 
                  ? 'image/gif' 
                  : 'application/octet-stream';
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'coverPhoto', // This must match the field name expected by your server
          imageFile.path,
          contentType: MediaType.parse(contentType),
        ),
      );
      
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // Fix the coverPhotoUrl to include the full base URL if it's a relative path
        String coverPhotoUrl = responseData['coverPhotoUrl'] ?? '';
        if (coverPhotoUrl.startsWith('/uploads/')) {
          coverPhotoUrl = 'http://192.168.254.140:3000$coverPhotoUrl';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cover photo for $serviceName updated successfully')),
        );
        
        return {
          'id': serviceId,
          'coverPhotoUrl': coverPhotoUrl,
        };
      } else {
        print('Failed to upload cover photo: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload cover photo: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      print('Error uploading cover photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading cover photo: $e')),
      );
      
      // Return local path for optimistic UI update
      return {
        'id': serviceId,
        'coverPhotoUrl': imageFile.path,
        'isLocal': true,
      };
    }
  }
}

// Widget to display and manage service cover photo
class ServiceCoverPhoto extends StatelessWidget {
  final String serviceId;
  final String serviceName;
  final String? coverPhotoUrl;
  final bool isLocal;
  final Color primaryColor;
  final Function(Map<String, dynamic>) onCoverPhotoUpdated;
  final ServiceCoverPhotoManager coverPhotoManager;

  const ServiceCoverPhoto({
    Key? key,
    required this.serviceId,
    required this.serviceName,
    this.coverPhotoUrl,
    this.isLocal = false,
    required this.primaryColor,
    required this.onCoverPhotoUpdated,
    required this.coverPhotoManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover photo header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cover Photo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await coverPhotoManager.pickAndUploadCoverPhoto(
                      context,
                      serviceId,
                      serviceName,
                    );
                    
                    if (result != null) {
                      onCoverPhotoUpdated(result);
                    }
                  },
                  icon: Icon(Icons.add_photo_alternate, size: 18, color: primaryColor),
                  label: Text(
                    coverPhotoUrl == null ? "Add Cover" : "Change Cover",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
          
          // Cover photo display or placeholder
          if (coverPhotoUrl == null)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "No cover photo",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  // Image
                  isLocal
                      ? Image.file(
                          File(coverPhotoUrl!),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          coverPhotoUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: primaryColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading cover photo: $error');
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.error_outline, color: Colors.red, size: 48),
                              ),
                            );
                          },
                        ),
                  
                  // Overlay with service name
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                      child: Text(
                        serviceName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

