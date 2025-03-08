import 'dart:io';
import 'package:eventhorizon/widgets/vendor_bottom_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventhorizon/screens/vendor_bookings_screen.dart' as vendorBookings;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  _VendorHomeScreenState createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  // Define the deep purple color as a constant for consistent usage
  final Color primaryColor = Colors.deepPurple;
  final Color primaryLightColor = Colors.deepPurple[100]!;
  
  List<Map<String, dynamic>> services = [];
  Map<String, dynamic> vendorProfile = {};
  bool isLoading = true;
  String? errorMessage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<String> portfolioImages = [];

  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadVendorProfile();
    _loadServices();
  }

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
        Uri.parse('http://10.0.2.2:3000/api/auth/me'),
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

  Future<void> _loadServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        return;
      }
      
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/vendor/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          services = List<Map<String, dynamic>>.from(responseData['services'] ?? []);
        });
      } else {
        // If API fails, use mock data
        setState(() {
          services = [
            {"title": "Wedding Photography", "price": "\$299/hr", "isActive": true},
            {"title": "Corporate Events", "price": "\$199/hr", "isActive": true},
            {"title": "Portrait Sessions", "price": "\$149/hr", "isActive": false},
          ];
        });
      }
    } catch (e) {
      print('Error loading services: $e');
      // Use mock data on error
      setState(() {
        services = [
          {"title": "Wedding Photography", "price": "\$299/hr", "isActive": true},
          {"title": "Corporate Events", "price": "\$199/hr", "isActive": true},
          {"title": "Portrait Sessions", "price": "\$149/hr", "isActive": false},
        ];
      });
    }
  }

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
        Uri.parse('http://10.0.2.2:3000/api/vendor/services/$serviceId/status'),
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

  void _addNewService() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both title and price")),
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
        Uri.parse('http://10.0.2.2:3000/api/vendor/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'price': _priceController.text,
          'isActive': false,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        setState(() {
          services.add(responseData['service'] ?? {
            "title": _titleController.text,
            "price": _priceController.text,
            "isActive": false,
          });
        });
        _titleController.clear();
        _priceController.clear();
        Navigator.pop(context); // Close the modal
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add service")),
        );
      }
    } catch (e) {
      print('Error adding service: $e');
      // Add service optimistically
      setState(() {
        services.add({
          "title": _titleController.text,
          "price": _priceController.text,
          "isActive": false,
        });
      });
      _titleController.clear();
      _priceController.clear();
      Navigator.pop(context); // Close the modal
    }
  }

  void _showAddServiceModal() {
    _titleController.clear();
    _priceController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add New Service", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Service Title",
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
                controller: _priceController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Service Price",
                  hintText: "e.g. 199/hr",
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

  void _showEditServiceModal(int index) {
    _titleController.text = services[index]["title"];
    _priceController.text = services[index]["price"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Service", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Service Title",
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
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "Service Price",
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
                  
                  final serviceId = services[index]['id'];
                  
                  final response = await http.put(
                    Uri.parse('http://10.0.2.2:3000/api/vendor/services/$serviceId'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      'title': _titleController.text,
                      'price': _priceController.text,
                    }),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      services[index]["title"] = _titleController.text;
                      services[index]["price"] = _priceController.text;
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to update service")),
                    );
                  }
                } catch (e) {
                  print('Error updating service: $e');
                  // Update optimistically
                  setState(() {
                    services[index]["title"] = _titleController.text;
                    services[index]["price"] = _priceController.text;
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        
        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication token not found. Please login again.')),
          );
          return;
        }
        
        // Here you would typically upload the image to your server
        // For now, we'll just add it to the local list
        setState(() {
          portfolioImages.add(image.path);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image added to portfolio')),
        );
      } catch (e) {
        print('Error adding image to portfolio: $e');
        // Add image optimistically
        setState(() {
          portfolioImages.add(image.path);
        });
      }
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 20),
                      _buildStatsGrid(context),
                      const SizedBox(height: 20),
                      _buildServicesSection(),
                      const SizedBox(height: 20),
                      _buildPortfolioSection(),
                      const SizedBox(height: 20),
                      _buildContactInfo(),
                      const SizedBox(height: 20),
                    ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Services", _isEditing ? "Done" : "Edit"),
          const SizedBox(height: 16),
          if (_isEditing)
            ...List.generate(services.length, (index) {
              return _buildEditableServiceItem(index);
            }),
          if (!_isEditing)
            ...List.generate(services.length, (index) {
              return _buildServiceItem(index);
            }),
          const SizedBox(height: 16),
          if (!_isEditing)
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
      ),
    );
  }

  Widget _buildEditableServiceItem(int index) {
    final service = services[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  service["price"],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
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
                      Uri.parse('http://10.0.2.2:3000/api/vendor/services/$serviceId'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                    );

                    if (response.statusCode == 200) {
                      setState(() {
                        services.removeAt(index);
                      });
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
    );
  }

  Widget _buildServiceItem(int index) {
    final service = services[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  service["price"],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
    );
  }

  Widget _buildPortfolioSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Portfolio", ""),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    "Add New Photo",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          portfolioImages.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: Text(
                    "No photos added yet",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: portfolioImages.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(portfolioImages[index]),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
        ],
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
          _buildSectionHeader("Contact Information", ""),
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

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        if (actionText.isNotEmpty)
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
            child: Text(actionText),
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