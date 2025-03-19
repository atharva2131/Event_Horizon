import 'dart:io';
import 'package:eventhorizon/widgets/vendor_bottom_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventhorizon/screens/vendor_bookings_screen.dart' as vendorBookings;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  _VendorHomeScreenState createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  // Define the deep purple color as a constant for consistent usage
  final Color primaryColor = Colors.deepPurple;
  final Color primaryLightColor = Colors.deepPurple[100]!;
  
  // Base API URL - change this to your actual API URL
  final String baseApiUrl = 'http://192.168.29.168:3000/api';
  
  // State variables
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> portfolioItems = [];
  Map<String, dynamic> vendorProfile = {};
  bool isLoading = true;
  bool isServicesLoading = false;
  bool isPortfolioLoading = false;
  String? errorMessage;

  // Controllers for form inputs
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescController = TextEditingController();
  final TextEditingController _serviceCategoryController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();
  
  final TextEditingController _portfolioTitleController = TextEditingController();
  final TextEditingController _portfolioDescController = TextEditingController();
  final TextEditingController _portfolioUrlController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  String? _selectedServiceId;
  File? _selectedImage;

  // Valid service categories from your Mongoose schema
  final List<String> validCategories = [
    "Photography",
    "Videography",
    "Catering",
    "Venue",
    "Music",
    "Decoration",
    "Transportation",
    "Accommodation",
    "Beauty",
    "Invitation",
    "Cake",
    "Flowers",
    "Lighting",
    "Entertainment",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    _loadVendorProfile();
    _loadServices();
    _loadPortfolio();
  }

  // Load vendor profile from API
  Future<void> _loadVendorProfile() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        setState(() {
          errorMessage = 'Authentication token not found. Please login again.';
          isLoading = false;
        });
        return;
      }
      
      final response = await http.get(
        Uri.parse('$baseApiUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          vendorProfile = responseData['user'] ?? {};
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load profile: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading profile: $e';
        isLoading = false;
      });
    }
  }

  // Load vendor services from API
  Future<void> _loadServices() async {
    setState(() => isServicesLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        setState(() {
          services = _getMockServices();
          isServicesLoading = false;
        });
        return;
      }
      
      final response = await http.get(
        Uri.parse('$baseApiUrl/vendors/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> servicesData = responseData['services'] ?? [];
        
        setState(() {
          services = servicesData.map((service) {
            // Transform API data to match our UI structure
            return {
              "id": service['_id'],
              "title": service['name'],
              "description": service['description'],
              "category": service['category'],
              "price": _formatPricing(service['pricing']),
              "isActive": service['isActive'] ?? false,
              "rating": service['averageRating'] ?? 0.0,
              "reviews": service['totalReviews'] ?? 0,
              "pricing": service['pricing'] ?? [],
            };
          }).toList();
          isServicesLoading = false;
        });
      } else {
        print('Error loading services: ${response.statusCode}');
        print('Response body: ${response.body}');
        // If API fails, use mock data
        setState(() {
          services = _getMockServices();
          isServicesLoading = false;
        });
      }
    } catch (e) {
      print('Error loading services: $e');
      // Use mock data on error
      setState(() {
        services = _getMockServices();
        isServicesLoading = false;
      });
    }
  }
  
  // Load vendor portfolio from API
  Future<void> _loadPortfolio() async {
    setState(() => isPortfolioLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        setState(() {
          portfolioItems = [];
          isPortfolioLoading = false;
        });
        return;
      }
      
      final response = await http.get(
        Uri.parse('$baseApiUrl/vendors/portfolio'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> portfolioData = responseData['portfolio'] ?? [];
        
        setState(() {
          portfolioItems = portfolioData.map((item) {
            // Fix the mediaUrl to include the full base URL if it's a relative path
            String mediaUrl = item['mediaUrl'];
            if (mediaUrl.startsWith('/uploads/')) {
              mediaUrl = 'http://192.168.29.168:3000$mediaUrl';
            }
            
            return {
              "id": item['_id'],
              "title": item['title'],
              "description": item['description'] ?? "",
              "mediaUrl": mediaUrl,
              "mediaType": item['mediaType'] ?? "image",
              "serviceId": item['serviceId'],
              "featured": item['featured'] ?? false,
            };
          }).toList();
          isPortfolioLoading = false;
        });
      } else {
        print('Error loading portfolio: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          portfolioItems = [];
          isPortfolioLoading = false;
        });
      }
    } catch (e) {
      print('Error loading portfolio: $e');
      setState(() {
        portfolioItems = [];
        isPortfolioLoading = false;
      });
    }
  }

  // Format pricing from API to display in UI
  String _formatPricing(List<dynamic>? pricing) {
    if (pricing == null || pricing.isEmpty) {
      return "\$0";
    }
    
    // Get the first pricing package
    final firstPackage = pricing[0];
    return "\$${firstPackage['price']}";
  }

  // Get mock services for fallback
  List<Map<String, dynamic>> _getMockServices() {
    return [
      {
        "id": "mock1",
        "title": "Wedding Photography",
        "description": "Professional wedding photography services",
        "category": "Photography",
        "price": "\$299/hr",
        "isActive": true,
        "rating": 4.8,
        "reviews": 24,
        "pricing": [
          {"name": "Basic", "price": 299, "description": "Basic package"}
        ],
      },
      {
        "id": "mock2",
        "title": "Corporate Events",
        "description": "Professional corporate event services",
        "category": "Photography",
        "price": "\$199/hr",
        "isActive": true,
        "rating": 4.5,
        "reviews": 18,
        "pricing": [
          {"name": "Standard", "price": 199, "description": "Standard package"}
        ],
      },
      {
        "id": "mock3",
        "title": "Portrait Sessions",
        "description": "Professional portrait photography",
        "category": "Photography",
        "price": "\$149/hr",
        "isActive": false,
        "rating": 4.7,
        "reviews": 15,
        "pricing": [
          {"name": "Basic", "price": 149, "description": "Basic package"}
        ],
      },
    ];
  }

  // Toggle service active status
  void _toggleServiceStatus(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }
      
      final serviceId = services[index]['id'];
      final newStatus = !services[index]["isActive"];
      
      final response = await http.put(
        Uri.parse('$baseApiUrl/vendors/services/$serviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'isActive': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          services[index]["isActive"] = newStatus;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service ${newStatus ? 'activated' : 'deactivated'} successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update service status')),
        );
      }
    } catch (e) {
      print('Error toggling service status: $e');
      // Update UI optimistically
      setState(() {
        services[index]["isActive"] = !services[index]["isActive"];
      });
    }
  }

  // Add a new service
  void _addNewService() async {
    if (_serviceNameController.text.isEmpty || 
        _serviceDescController.text.isEmpty || 
        _serviceCategoryController.text.isEmpty || 
        _servicePriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    // Validate category against the allowed list
    String category = _serviceCategoryController.text.trim();
    // Capitalize first letter to match enum format
    category = category[0].toUpperCase() + category.substring(1).toLowerCase();
    
    if (!validCategories.contains(category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid category. Please choose from: ${validCategories.join(', ')}")),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }
      
      // Parse price to ensure it's a number
      final priceText = _servicePriceController.text.replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.tryParse(priceText) ?? 0;
      
      // Fixed request format to match backend expectations
      final response = await http.post(
        Uri.parse('$baseApiUrl/vendors/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _serviceNameController.text,
          'description': _serviceDescController.text,
          'category': category, // Use validated category
          'pricing': [
            {
              'name': 'Standard',
              'price': price,
              'description': 'Standard package'
            }
          ],
          'tags': [],
          'isActive': true
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final newService = responseData['service'];
        
        setState(() {
          services.add({
            "id": newService['_id'],
            "title": newService['name'],
            "description": newService['description'],
            "category": newService['category'],
            "price": "\$${price.toString()}",
            "isActive": newService['isActive'] ?? true,
            "rating": 0.0,
            "reviews": 0,
            "pricing": newService['pricing'] ?? [],
          });
        });
        
        _serviceNameController.clear();
        _serviceDescController.clear();
        _serviceCategoryController.clear();
        _servicePriceController.clear();
        
        Navigator.pop(context); // Close the modal
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Service added successfully")),
        );
      } else {
        print('Failed to add service: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add service: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('Error adding service: $e');
      // Add service optimistically
      setState(() {
        services.add({
          "id": "temp_${DateTime.now().millisecondsSinceEpoch}",
          "title": _serviceNameController.text,
          "description": _serviceDescController.text,
          "category": _serviceCategoryController.text,
          "price": "\$${_servicePriceController.text}",
          "isActive": true,
          "rating": 0.0,
          "reviews": 0,
          "pricing": [
            {
              "name": "Standard",
              "price": double.tryParse(_servicePriceController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
              "description": "Standard package"
            }
          ],
        });
      });
      
      _serviceNameController.clear();
      _serviceDescController.clear();
      _serviceCategoryController.clear();
      _servicePriceController.clear();
      
      Navigator.pop(context); // Close the modal
    }
  }

  // Show modal to add a new service
  void _showAddServiceModal() {
    _serviceNameController.clear();
    _serviceDescController.clear();
    _serviceCategoryController.clear();
    _servicePriceController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add New Service", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _serviceNameController,
                  decoration: InputDecoration(
                    labelText: "Service Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _serviceDescController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Replace TextField with DropdownButtonFormField for category
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                  items: validCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _serviceCategoryController.text = newValue;
                    }
                  },
                  hint: const Text("Select a category"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _servicePriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Price",
                    hintText: "e.g. 199",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    prefixText: "\$ ",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _addNewService,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Add Service"),
            ),
          ],
        );
      },
    );
  }

  // Show modal to edit an existing service
  void _showEditServiceModal(int index) {
    final service = services[index];
    _serviceNameController.text = service["title"];
    _serviceDescController.text = service["description"] ?? "";
    _serviceCategoryController.text = service["category"] ?? "";
    _servicePriceController.text = service["price"].toString().replaceAll(RegExp(r'[^\d.]'), '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Service", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _serviceNameController,
                  decoration: InputDecoration(
                    labelText: "Service Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _serviceDescController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Replace TextField with DropdownButtonFormField for category
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                  value: validCategories.contains(service["category"]) ? service["category"] : null,
                  items: validCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _serviceCategoryController.text = newValue;
                    }
                  },
                  hint: const Text("Select a category"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _servicePriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    prefixText: "\$ ",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token');
                  
                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Authentication token not found. Please login again.')),
                    );
                    return;
                  }
                  
                  final serviceId = services[index]['id'];
                  final price = double.tryParse(_servicePriceController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
                  
                  // Validate category
                  String category = _serviceCategoryController.text;
                  if (!validCategories.contains(category)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Invalid category. Please choose from: ${validCategories.join(', ')}")),
                    );
                    return;
                  }
                  
                  final response = await http.put(
                    Uri.parse('$baseApiUrl/vendors/services/$serviceId'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      'name': _serviceNameController.text,
                      'description': _serviceDescController.text,
                      'category': category,
                      'pricing': [
                        {
                          'name': 'Standard',
                          'price': price,
                          'description': 'Standard package for ${_serviceNameController.text}'
                        }
                      ],
                    }),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      services[index]["title"] = _serviceNameController.text;
                      services[index]["description"] = _serviceDescController.text;
                      services[index]["category"] = category;
                      services[index]["price"] = "\$${price.toString()}";
                    });
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Service updated successfully")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to update service")),
                    );
                  }
                } catch (e) {
                  print('Error updating service: $e');
                  // Update optimistically
                  setState(() {
                    services[index]["title"] = _serviceNameController.text;
                    services[index]["description"] = _serviceDescController.text;
                    services[index]["category"] = _serviceCategoryController.text;
                    services[index]["price"] = "\$${_servicePriceController.text}";
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  // Show modal to add a new portfolio item
  void _showAddPortfolioModal(String? serviceId, String serviceName) {
    _portfolioTitleController.clear();
    _portfolioDescController.clear();
    _portfolioUrlController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Add Portfolio Item for $serviceName", 
            style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _portfolioTitleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _portfolioDescController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _portfolioUrlController,
                  decoration: InputDecoration(
                    labelText: "Media URL",
                    hintText: "https://example.com/image.jpg",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_portfolioTitleController.text.isEmpty || _portfolioUrlController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Title and Media URL are required")),
                  );
                  return;
                }
                
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token');
                  
                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Authentication token not found. Please login again.')),
                    );
                    return;
                  }
                  
                  final response = await http.post(
                    Uri.parse('$baseApiUrl/vendors/portfolio'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      'title': _portfolioTitleController.text,
                      'description': _portfolioDescController.text,
                      'mediaUrl': _portfolioUrlController.text,
                      'mediaType': 'image',
                      'serviceId': serviceId,
                    }),
                  );

                  if (response.statusCode == 201) {
                    final responseData = json.decode(response.body);
                    final newItem = responseData['portfolioItem'];
                    
                    // Fix the mediaUrl to include the full base URL if it's a relative path
                    String mediaUrl = newItem['mediaUrl'];
                    if (mediaUrl.startsWith('/uploads/')) {
                      mediaUrl = 'http://192.168.29.168:3000$mediaUrl';
                    }
                    
                    setState(() {
                      portfolioItems.add({
                        "id": newItem['_id'],
                        "title": newItem['title'],
                        "description": newItem['description'] ?? "",
                        "mediaUrl": mediaUrl,
                        "mediaType": newItem['mediaType'] ?? "image",
                        "serviceId": newItem['serviceId'],
                        "featured": newItem['featured'] ?? false,
                      });
                    });
                    
                    _portfolioTitleController.clear();
                    _portfolioDescController.clear();
                    _portfolioUrlController.clear();
                    
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Portfolio item added successfully")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add portfolio item: ${response.statusCode}")),
                    );
                  }
                } catch (e) {
                  print('Error adding portfolio item: $e');
                  // Add item optimistically
                  setState(() {
                    portfolioItems.add({
                      "id": "temp_${DateTime.now().millisecondsSinceEpoch}",
                      "title": _portfolioTitleController.text,
                      "description": _portfolioDescController.text,
                      "mediaUrl": _portfolioUrlController.text,
                      "mediaType": "image",
                      "serviceId": serviceId,
                      "featured": false,
                    });
                  });
                  
                  _portfolioTitleController.clear();
                  _portfolioDescController.clear();
                  _portfolioUrlController.clear();
                  
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Add Item"),
            ),
          ],
        );
      },
    );
  }

  // Pick image from gallery and upload to portfolio
  Future<void> _pickImage(String? serviceId, String serviceName) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      
      // Show a dialog to get title and description
      _portfolioTitleController.text = "New Portfolio Item";
      _portfolioDescController.text = "";
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Add to $serviceName Portfolio", style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _portfolioTitleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _portfolioDescController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('token');
                    
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authentication token not found. Please login again.')),
                      );
                      return;
                    }
                    
                    // Create multipart request for file upload
                    var request = http.MultipartRequest(
                      'POST',
                      Uri.parse('$baseApiUrl/vendors/portfolio'),
                    );
                    
                    // Add authorization header
                    request.headers.addAll({
                      'Authorization': 'Bearer $token',
                    });
                    
                    // Add text fields
                    request.fields['title'] = _portfolioTitleController.text;
                    request.fields['description'] = _portfolioDescController.text;
                    if (serviceId != null) {
                      request.fields['serviceId'] = serviceId;
                    }
                    
                    // Determine file type
                    final ext = path.extension(_selectedImage!.path).toLowerCase();
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
                        'media', // This must match the field name expected by your server
                        _selectedImage!.path,
                        contentType: MediaType.parse(contentType),
                      ),
                    );
                    
                    // Send request
                    var streamedResponse = await request.send();
                    var response = await http.Response.fromStream(streamedResponse);
                    
                    if (response.statusCode == 201) {
                      final responseData = json.decode(response.body);
                      final newItem = responseData['portfolioItem'];
                      
                      // Fix the mediaUrl to include the full base URL if it's a relative path
                      String mediaUrl = newItem['mediaUrl'];
                      if (mediaUrl.startsWith('/uploads/')) {
                        mediaUrl = 'http://192.168.29.168:3000$mediaUrl';
                      }
                      
                      setState(() {
                        portfolioItems.add({
                          "id": newItem['_id'],
                          "title": newItem['title'],
                          "description": newItem['description'] ?? "",
                          "mediaUrl": mediaUrl,
                          "mediaType": newItem['mediaType'] ?? "image",
                          "serviceId": newItem['serviceId'],
                          "featured": newItem['featured'] ?? false,
                        });
                      });
                      
                      _portfolioTitleController.clear();
                      _portfolioDescController.clear();
                      _selectedImage = null;
                      
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Image added to portfolio successfully')),
                      );
                    } else {
                      print('Failed to upload image: ${response.statusCode}');
                      print('Response body: ${response.body}');
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to upload image: ${response.statusCode}')),
                      );
                    }
                  } catch (e) {
                    print('Error adding image to portfolio: $e');
                    // Add image optimistically
                    setState(() {
                      portfolioItems.add({
                        "id": "local_${DateTime.now().millisecondsSinceEpoch}",
                        "title": _portfolioTitleController.text,
                        "description": _portfolioDescController.text,
                        "mediaUrl": _selectedImage!.path,
                        "mediaType": "image",
                        "serviceId": serviceId,
                        "isLocal": true,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text("Add to Portfolio"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Vendor Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadVendorProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadVendorProfile();
                    await _loadServices();
                    await _loadPortfolio();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 20),
                        _buildStatsGrid(context),
                        const SizedBox(height: 20),
                        _buildServicesSection(),
                        const SizedBox(height: 20),
                        _buildContactInfo(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceModal,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VendorBottomNavScreen(initialIndex: 4), // Profile tab in the Bottom Nav
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _boxDecoration(
          color: primaryColor,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      vendorProfile['avatar_url'] ?? "https://via.placeholder.com/150",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendorProfile['name'] ?? "Vendor Name",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          final rating = vendorProfile['rating'] ?? 0;
                          return Icon(
                            index < rating.floor() ? Icons.star : 
                            (index == rating.floor() && rating % 1 > 0) ? Icons.star_half : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vendorProfile['business_type'] ?? "Professional Service",
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vendorProfile['status'] ?? "Active",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ProfileStat(label: "Bookings", value: vendorProfile['bookings_count']?.toString() ?? "0"),
                  _ProfileStat(label: "Reviews", value: vendorProfile['rating']?.toString() ?? "0"),
                  _ProfileStat(label: "Completed", value: vendorProfile['completed_events']?.toString() ?? "0"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          Icons.calendar_today,
          "New Bookings",
          vendorProfile['new_bookings']?.toString() ?? "0",
          Colors.orange[400]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const vendorBookings.VendorBookingsScreen()),
            );
          },
        ),
        _buildStatCard(
          Icons.star,
          "Pending Reviews",
          vendorProfile['pending_reviews']?.toString() ?? "0",
          primaryColor,
        ),
        _buildStatCard(
          Icons.attach_money,
          "Total Revenue",
          "\$${vendorProfile['total_revenue']?.toString() ?? "0"}",
          Colors.green[400]!,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: _boxDecoration(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      children: [
        if (isServicesLoading)
          Center(child: CircularProgressIndicator(color: primaryColor))
        else if (services.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: Text(
              "No services added yet",
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          ...List.generate(services.length, (index) {
            return _buildServiceWithPortfolio(index);
          }),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _showAddServiceModal,
          child: Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  "Add New Service",
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceWithPortfolio(int index) {
    final service = services[index];
    final serviceId = service["id"];
    final servicePortfolio = portfolioItems.where((item) => item["serviceId"] == serviceId).toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service["title"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                      ),
                      if (service["category"] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              service["category"],
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: service["isActive"],
                  activeColor: primaryColor,
                  onChanged: (value) {
                    _toggleServiceStatus(index);
                  },
                ),
              ],
            ),
          ),
          
          // Service details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service["description"] != null && service["description"].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      service["description"],
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Price: ${service["price"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: primaryColor),
                          onPressed: () {
                            _showEditServiceModal(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              
                              if (token == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Authentication token not found. Please login again.')),
                                );
                                return;
                              }
                              
                              final serviceId = services[index]['id'];
                              
                              final response = await http.delete(
                                Uri.parse('$baseApiUrl/vendors/services/$serviceId'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                              );

                              if (response.statusCode == 200) {
                                setState(() {
                                  services.removeAt(index);
                                });
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Service deleted successfully")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Failed to delete service")),
                                );
                              }
                            } catch (e) {
                              print('Error deleting service: $e');
                              // Delete optimistically
                              setState(() {
                                services.removeAt(index);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Portfolio section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Portfolio",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddPortfolioModal(serviceId, service["title"]),
                      icon: Icon(Icons.add_link, size: 18, color: primaryColor),
                      label: Text("Add URL", style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickImage(serviceId, service["title"]),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "Add Photo",
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (isPortfolioLoading)
                  Center(child: CircularProgressIndicator(color: primaryColor))
                else if (servicePortfolio.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: Text(
                      "No portfolio items for this service",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: servicePortfolio.length,
                    itemBuilder: (context, idx) {
                      final item = servicePortfolio[idx];
                      return _buildPortfolioItem(item);
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            item['isLocal'] == true
                ? Image.file(
                    File(item['mediaUrl']),
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    item['mediaUrl'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: primaryColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.error_outline, color: Colors.red),
                        ),
                      );
                    },
                  ),
            
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            
            // Title and description
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item['description'] != null && item['description'].toString().isNotEmpty)
                      Text(
                        item['description'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
            
            // Delete button
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () async {
                  try {
                    if (item['isLocal'] == true) {
                      setState(() {
                        portfolioItems.removeWhere((element) => element['id'] == item['id']);
                      });
                      return;
                    }
                    
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('token');
                    
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authentication token not found. Please login again.')),
                      );
                      return;
                    }
                    
                    final itemId = item['id'];
                    
                    final response = await http.delete(
                      Uri.parse('$baseApiUrl/vendors/portfolio/$itemId'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                    );

                    if (response.statusCode == 200) {
                      setState(() {
                        portfolioItems.removeWhere((element) => element['id'] == itemId);
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Portfolio item deleted successfully")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to delete portfolio item")),
                      );
                    }
                  } catch (e) {
                    print('Error deleting portfolio item: $e');
                    // Delete optimistically
                    setState(() {
                      portfolioItems.removeWhere((element) => element['id'] == item['id']);
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Contact Information",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.email, vendorProfile['email'] ?? "contact@example.com"),
          const SizedBox(height: 12),
          _buildContactItem(Icons.phone, vendorProfile['phone'] ?? "+1 (555) 123-4567"),
          const SizedBox(height: 12),
          _buildContactItem(Icons.location_on, vendorProfile['address'] ?? "123 Business Lane, City, Country"),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryLightColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  BoxDecoration _boxDecoration({Color color = Colors.white, Color? shadowColor}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: color,
      boxShadow: [
        BoxShadow(
          color: shadowColor ?? Colors.black.withOpacity(0.05),
          spreadRadius: 0,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}