import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'api_services.dart';

class EventService {
  // Get all events
  Future<List<Map<String, dynamic>>> getEvents({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      String endpoint = '/events?page=$page&limit=$limit';
      
      if (search != null) endpoint += '&search=$search';
      if (category != null) endpoint += '&category=$category';
      if (sortBy != null) endpoint += '&sortBy=$sortBy';
      if (sortOrder != null) endpoint += '&sortOrder=$sortOrder';
      
      final response = await ApiService.get(endpoint);
      print('Events response: $response');
      
      // Check if response contains events array
      if (response != null && response['events'] != null) {
        List<dynamic> eventsList = response['events'];
        List<Map<String, dynamic>> formattedEvents = [];
        
        for (var eventData in eventsList) {
          try {
            print('Processing event: ${eventData['_id']}');
            
            // Format date and time
            DateTime eventDate;
            String formattedDate;
            String formattedTime;
            
            // Handle different date formats
            if (eventData['eventDate'] != null) {
              eventDate = DateTime.parse(eventData['eventDate']);
              formattedDate = "${eventDate.day}/${eventDate.month}/${eventDate.year}";
              
              // Use eventTime if available, otherwise extract from eventDate
              if (eventData['eventTime'] != null) {
                formattedTime = eventData['eventTime'];
              } else {
                formattedTime = "${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}";
              }
            } else {
              formattedDate = "No date";
              formattedTime = "No time";
            }
            
            // Process guests
            List<Map<String, dynamic>> formattedGuests = [];
            if (eventData['guests'] != null) {
              for (var guest in eventData['guests']) {
                String status = 'Not Invited';
                if (guest['inviteSent'] == true) {
                  if (guest['rsvpStatus'] == 'pending') {
                    status = 'Invited';
                  } else if (guest['rsvpStatus'] == 'confirmed') {
                    status = 'Confirmed';
                  } else if (guest['rsvpStatus'] == 'declined') {
                    status = 'Declined';
                  } else if (guest['rsvpStatus'] == 'maybe') {
                    status = 'Maybe';
                  }
                }
                
                formattedGuests.add({
                  'name': guest['name'] ?? '',
                  'email': guest['email'] ?? '',
                  'phone': guest['phone'] ?? '',
                  'status': status,
                });
              }
            }
            
            // Get image URL with proper path
            String imageUrl = '';
            if (eventData['eventImage'] != null && eventData['eventImage'].toString().isNotEmpty) {
              // If it's already a full URL, use it directly
              if (eventData['eventImage'].toString().startsWith('http')) {
                imageUrl = eventData['eventImage'];
              } else {
                // Otherwise, construct the full URL
                imageUrl = '${ApiService.baseUrl}${eventData['eventImage']}';
              }
            }
            
            formattedEvents.add({
              'id': eventData['_id'],
              'name': eventData['eventName'],
              'date': formattedDate,
              'time': formattedTime,
              'location': eventData['location'],
              'description': eventData['description'],
              'budget': eventData['budget']?.toString(),
              'type': eventData['category'],
              'image_url': imageUrl,
              'guests': formattedGuests,
            });
          } catch (e) {
            print('Error formatting event: $e');
            // Skip this event if there's an error
          }
        }
        
        print('Formatted ${formattedEvents.length} events');
        return formattedEvents;
      } else {
        print('No events found in response');
        // If no events or unexpected format, return empty list
        return [];
      }
    } catch (e) {
      print('Error fetching events: $e');
      // Return empty list on error instead of throwing
      return [];
    }
  }

  // Get event by ID
  Future<Map<String, dynamic>?> getEventById(String id) async {
    try {
      final response = await ApiService.get('/events/$id');
      if (response != null && response['event'] != null) {
        final eventData = response['event'];
        
        // Format date and time
        DateTime eventDate;
        String formattedDate;
        String formattedTime;
        
        // Handle different date formats
        if (eventData['eventDate'] != null) {
          eventDate = DateTime.parse(eventData['eventDate']);
          formattedDate = "${eventDate.day}/${eventDate.month}/${eventDate.year}";
          
          // Use eventTime if available, otherwise extract from eventDate
          if (eventData['eventTime'] != null) {
            formattedTime = eventData['eventTime'];
          } else {
            formattedTime = "${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}";
          }
        } else {
          formattedDate = "No date";
          formattedTime = "No time";
        }
        
        // Process guests
        List<Map<String, dynamic>> formattedGuests = [];
        if (eventData['guests'] != null) {
          for (var guest in eventData['guests']) {
            String status = 'Not Invited';
            if (guest['inviteSent'] == true) {
              if (guest['rsvpStatus'] == 'pending') {
                status = 'Invited';
              } else if (guest['rsvpStatus'] == 'confirmed') {
                status = 'Confirmed';
              } else if (guest['rsvpStatus'] == 'declined') {
                status = 'Declined';
              } else if (guest['rsvpStatus'] == 'maybe') {
                status = 'Maybe';
              }
            }
            
            formattedGuests.add({
              'name': guest['name'] ?? '',
              'email': guest['email'] ?? '',
              'phone': guest['phone'] ?? '',
              'status': status,
            });
          }
        }
        
        // Get image URL with proper path
        String imageUrl = '';
        if (eventData['eventImage'] != null && eventData['eventImage'].toString().isNotEmpty) {
          // If it's already a full URL, use it directly
          if (eventData['eventImage'].toString().startsWith('http')) {
            imageUrl = eventData['eventImage'];
          } else {
            // Otherwise, construct the full URL
            imageUrl = '${ApiService.baseUrl}${eventData['eventImage']}';
          }
        }
        
        return {
          'id': eventData['_id'],
          'name': eventData['eventName'],
          'date': formattedDate,
          'time': formattedTime,
          'location': eventData['location'],
          'description': eventData['description'],
          'budget': eventData['budget']?.toString(),
          'type': eventData['category'],
          'image_url': imageUrl,
          'guests': formattedGuests,
        };
      }
      return null;
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }

  // Create a new event - direct API format
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    try {
      // Print the event data for debugging
      print('Creating event with data: $eventData');
      
      // Send directly to API
      final response = await ApiService.post('/events', eventData);
      
      if (response != null && response['event'] != null) {
        print('Event created successfully: ${response['event']}');
        return response['event'];
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error creating event: $e');
      throw Exception('Error creating event: $e');
    }
  }
  
  // Update an event
  Future<Map<String, dynamic>> updateEvent(String id, Map<String, dynamic> eventData) async {
    try {
      // Send directly to API
      final response = await ApiService.put('/events/$id', eventData);
      
      if (response != null && response['event'] != null) {
        return response['event'];
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error updating event: $e');
      throw Exception('Error updating event: $e');
    }
  }
  
  // Delete an event
  Future<bool> deleteEvent(String id) async {
    try {
      final response = await ApiService.delete('/events/$id');
      return response['success'] ?? false;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }
  
  // Add a guest to an event
  Future<Map<String, dynamic>> addGuest(String eventId, Map<String, dynamic> guestData) async {
    try {
      // Convert from app format to API format
      String rsvpStatus;
      bool inviteSent = false;
      
      switch (guestData['status']) {
        case 'Confirmed':
          rsvpStatus = 'confirmed';
          inviteSent = true;
          break;
        case 'Declined':
          rsvpStatus = 'declined';
          inviteSent = true;
          break;
        case 'Maybe':
          rsvpStatus = 'maybe';
          inviteSent = true;
          break;
        case 'Invited':
          rsvpStatus = 'pending';
          inviteSent = true;
          break;
        default:
          rsvpStatus = 'pending';
          inviteSent = false;
      }
      
      final apiGuestData = {
        'name': guestData['name'],
        'email': guestData['email'],
        'phone': guestData['phone'],
        'rsvpStatus': rsvpStatus,
        'inviteSent': inviteSent,
        'source': 'manual',
      };
      
      // Send to API
      final response = await ApiService.post('/events/$eventId/guests', apiGuestData);
      
      if (response != null && response['guest'] != null) {
        final addedGuest = response['guest'];
        
        // Convert to app format
        String status = 'Not Invited';
        if (addedGuest['inviteSent'] == true) {
          if (addedGuest['rsvpStatus'] == 'pending') {
            status = 'Invited';
          } else if (addedGuest['rsvpStatus'] == 'confirmed') {
            status = 'Confirmed';
          } else if (addedGuest['rsvpStatus'] == 'declined') {
            status = 'Declined';
          } else if (addedGuest['rsvpStatus'] == 'maybe') {
            status = 'Maybe';
          }
        }
        
        return {
          'name': addedGuest['name'] ?? '',
          'email': addedGuest['email'] ?? '',
          'phone': addedGuest['phone'] ?? '',
          'status': status,
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error adding guest: $e');
      throw Exception('Error adding guest: $e');
    }
  }
  
  // Remove a guest from an event
  Future<bool> removeGuest(String eventId, String email) async {
    try {
      final response = await ApiService.delete('/events/$eventId/guests/$email');
      return response['success'] ?? false;
    } catch (e) {
      print('Error removing guest: $e');
      return false;
    }
  }
  
  // Update guest RSVP status
  Future<Map<String, dynamic>> updateGuestRsvp(String eventId, String email, String appRsvpStatus) async {
    try {
      // Convert from app format to API format
      String apiRsvpStatus;
      
      switch (appRsvpStatus) {
        case 'Confirmed':
          apiRsvpStatus = 'confirmed';
          break;
        case 'Declined':
          apiRsvpStatus = 'declined';
          break;
        case 'Maybe':
          apiRsvpStatus = 'maybe';
          break;
        default:
          apiRsvpStatus = 'pending';
      }
      
      // Send to API
      final response = await ApiService.put('/events/$eventId/guests/$email/rsvp', {
        'rsvpStatus': apiRsvpStatus
      });
      
      if (response != null && response['guest'] != null) {
        final updatedGuest = response['guest'];
        
        // Convert to app format
        String status = 'Not Invited';
        if (updatedGuest['inviteSent'] == true) {
          if (updatedGuest['rsvpStatus'] == 'pending') {
            status = 'Invited';
          } else if (updatedGuest['rsvpStatus'] == 'confirmed') {
            status = 'Confirmed';
          } else if (updatedGuest['rsvpStatus'] == 'declined') {
            status = 'Declined';
          } else if (updatedGuest['rsvpStatus'] == 'maybe') {
            status = 'Maybe';
          }
        }
        
        return {
          'name': updatedGuest['name'] ?? '',
          'email': updatedGuest['email'] ?? '',
          'phone': updatedGuest['phone'] ?? '',
          'status': status,
        };
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error updating guest RSVP: $e');
      throw Exception('Error updating guest RSVP: $e');
    }
  }
  
  // Send invitations to guests
  Future<Map<String, dynamic>> sendInvitations(String eventId, List<String> guestEmails) async {
    try {
      final response = await ApiService.post('/events/$eventId/send-invitations', {
        'guestEmails': guestEmails
      });
      return response;
    } catch (e) {
      print('Error sending invitations: $e');
      throw Exception('Error sending invitations: $e');
    }
  }
  
  // Import guests from contacts
  Future<Map<String, dynamic>> importGuests(String eventId, List<Map<String, dynamic>> contacts) async {
    try {
      final response = await ApiService.post('/events/$eventId/import-guests', {
        'contacts': contacts
      });
      return response;
    } catch (e) {
      print('Error importing guests: $e');
      throw Exception('Error importing guests: $e');
    }
  }
  
  // Upload event cover image - FIXED VERSION
  Future<String> uploadEventImage(String eventId, File imageFile) async {
    try {
      // Check if file exists and has content
      if (!(await imageFile.exists())) {
        throw Exception('Image file does not exist');
      }
      
      final fileLength = await imageFile.length();
      if (fileLength == 0) {
        throw Exception('Image file is empty');
      }
      
      print('Uploading image for event: $eventId');
      print('Image file path: ${imageFile.path}');
      print('Image file size: $fileLength bytes');
      
      // Get token for authorization
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      // Try direct HTTP request instead of MultipartRequest
      final uri = Uri.parse('${ApiService.baseUrl}/events/$eventId/upload-image');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Get file extension and determine content type
      final fileExtension = extension(imageFile.path).toLowerCase();
      String contentType;
      
      if (fileExtension == '.png') {
        contentType = 'image/png';
      } else if (fileExtension == '.gif') {
        contentType = 'image/gif';
      } else if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
        contentType = 'image/jpeg';
      } else {
        // Default to JPEG if unknown
        contentType = 'image/jpeg';
      }
      
      print('Content type: $contentType');
      
      // Try different field names that the server might be expecting
      // First try 'image' which is common
      final fileName = basename(imageFile.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'image',  // Field name - try 'image' first
        imageFile.path,
        contentType: MediaType(contentType.split('/')[0], contentType.split('/')[1]),
        filename: fileName,
      );
      
      request.files.add(multipartFile);
      
      // Send request
      print('Sending image upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Image upload response status: ${response.statusCode}');
      print('Image upload response body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Try to parse the response
        try {
          final responseData = json.decode(response.body);
          
          // Check for different response formats
          String? imageUrl;
          
          if (responseData['eventImage'] != null) {
            imageUrl = responseData['eventImage'];
          } else if (responseData['imageUrl'] != null) {
            imageUrl = responseData['imageUrl'];
          } else if (responseData['event'] != null && responseData['event']['eventImage'] != null) {
            imageUrl = responseData['event']['eventImage'];
          } else if (responseData['image'] != null) {
            imageUrl = responseData['image'];
          } else if (responseData['url'] != null) {
            imageUrl = responseData['url'];
          }
          
          if (imageUrl != null) {
            // Return the full URL
            if (!imageUrl.startsWith('http')) {
              imageUrl = '${ApiService.baseUrl}$imageUrl';
            }
            return imageUrl;
          } else {
            // If we can't find the image URL in the response, try to update the event
            // with the image URL from the response directly
            await updateEvent(eventId, {'eventImage': responseData.toString()});
            return 'Image uploaded successfully';
          }
        } catch (e) {
          print('Error parsing response: $e');
          throw Exception('Failed to parse image upload response: $e');
        }
      } else if (response.statusCode == 400) {
        // Try with a different field name if 400 error
        print('Trying with different field name...');
        
        // Create a new request with 'eventImage' field name
        final retryRequest = http.MultipartRequest('POST', uri);
        retryRequest.headers['Authorization'] = 'Bearer $token';
        
        final retryFile = await http.MultipartFile.fromPath(
          'eventImage',  // Try 'eventImage' as field name
          imageFile.path,
          contentType: MediaType(contentType.split('/')[0], contentType.split('/')[1]),
          filename: fileName,
        );
        
        retryRequest.files.add(retryFile);
        
        final retryResponse = await retryRequest.send();
        final retryResponseData = await http.Response.fromStream(retryResponse);
        
        print('Retry response status: ${retryResponseData.statusCode}');
        print('Retry response body: ${retryResponseData.body}');
        
        if (retryResponseData.statusCode >= 200 && retryResponseData.statusCode < 300) {
          try {
            final responseData = json.decode(retryResponseData.body);
            
            String? imageUrl;
            if (responseData['eventImage'] != null) {
              imageUrl = responseData['eventImage'];
            } else if (responseData['imageUrl'] != null) {
              imageUrl = responseData['imageUrl'];
            } else if (responseData['event'] != null && responseData['event']['eventImage'] != null) {
              imageUrl = responseData['event']['eventImage'];
            }
            
            if (imageUrl != null) {
              if (!imageUrl.startsWith('http')) {
                imageUrl = '${ApiService.baseUrl}$imageUrl';
              }
              return imageUrl;
            }
          } catch (e) {
            print('Error parsing retry response: $e');
          }
        }
        
        // If both attempts fail, try a direct update with the file path
        try {
          await updateEvent(eventId, {'eventImage': imageFile.path});
          return imageFile.path;
        } catch (e) {
          print('Error updating event with image path: $e');
          throw Exception('Failed to upload image after multiple attempts');
        }
      } else {
        // Try to parse error message
        try {
          final errorData = json.decode(response.body);
          throw Exception('Failed to upload image: ${errorData['msg'] ?? errorData['message'] ?? response.statusCode}');
        } catch (e) {
          throw Exception('Failed to upload image: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Error uploading image: $e');
    }
  }
} 