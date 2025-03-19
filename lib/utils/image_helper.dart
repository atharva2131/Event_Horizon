// lib/helpers/image_helper.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_services.dart';

class ImageHelper {
  static Widget displayEventImage(String? imageUrl, {double height = 180, double width = double.infinity}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholder(height, width);
    }
    
    // Debug the image URL
    print('Displaying image from URL: $imageUrl');
    
    // Case 1: Full URL starting with http or https
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return _buildNetworkImage(imageUrl, height, width);
    }
    
    // Case 2: Local file path
    if (imageUrl.startsWith('/') && !imageUrl.startsWith('/uploads')) {
      return _buildFileImage(imageUrl, height, width);
    }
    
    // Case 3: Relative path from API (starts with /uploads)
    if (imageUrl.startsWith('/uploads')) {
      // FIXED: Construct the URL correctly by removing 'api' from the path
      final baseUrlWithoutApi = ApiService.baseUrl.replaceAll('/api', '');
      final fullUrl = '$baseUrlWithoutApi$imageUrl';
      print('Constructed full URL: $fullUrl');
      return _buildNetworkImage(fullUrl, height, width);
    }
    
    // Default case: Try as a network image
    return _buildNetworkImage(imageUrl, height, width);
  }
  
  static Widget _buildNetworkImage(String url, double height, double width) {
    return Image.network(
      url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading network image: $error');
        return _buildPlaceholder(height, width);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
  
  static Widget _buildFileImage(String path, double height, double width) {
    return FutureBuilder<bool>(
      future: File(path).exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData && snapshot.data == true) {
          return Image.file(
            File(path),
            height: height,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading file image: $error');
              return _buildPlaceholder(height, width);
            },
          );
        }
        
        // File doesn't exist, try as a relative URL
        final fullUrl = '${ApiService.baseUrl}$path';
        print('File not found, trying as URL: $fullUrl');
        return _buildNetworkImage(fullUrl, height, width);
      },
    );
  }
  
  static Widget _buildPlaceholder(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.image,
          size: 50,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}