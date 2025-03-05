import 'dart:io';
import 'package:eventhorizon/screens/user_vendor_bookings_screen.dart';
import 'package:eventhorizon/screens/vendor_bookings_screen.dart';
import 'package:eventhorizon/widgets/vendor_bottom_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventhorizon/screens/vendor_bookings_screen.dart' as vendorBookings;

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  _VendorHomeScreenState createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  // Define the deep purple color as a constant for consistent usage
  final Color primaryColor = Colors.deepPurple;
  final Color primaryLightColor = Colors.deepPurple[100]!;
  
  List<Map<String, dynamic>> services = [
    {"title": "Wedding Photography", "price": "\$299/hr", "isActive": true},
    {"title": "Corporate Events", "price": "\$199/hr", "isActive": true},
    {"title": "Portrait Sessions", "price": "\$149/hr", "isActive": false},
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<String> portfolioImages = [];

  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;

  void _toggleServiceStatus(int index) {
    setState(() {
      services[index]["isActive"] = !services[index]["isActive"];
    });
  }

  void _addNewService() {
    if (_titleController.text.isNotEmpty && _priceController.text.isNotEmpty) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both title and price")),
      );
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
                keyboardType: TextInputType.number,
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
              onPressed: () {
                setState(() {
                  services[index]["title"] = _titleController.text;
                  services[index]["price"] = _priceController.text;
                });
                Navigator.pop(context);
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
      setState(() {
        portfolioImages.add(image.path); // Add selected image to portfolio
      });
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
      body: SingleChildScrollView(
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
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      "https://storage.googleapis.com/a1aa/image/Pb6FWzcRzBLYGzQ40URCBIxsSIr4ZsbQaHF0_hv9KDw.jpg",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Studio Creative",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_half,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Professional Photography",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
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
                  child: const Text(
                    "Active",
                    style: TextStyle(
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ProfileStat(label: "Bookings", value: "24"),
                  _ProfileStat(label: "Reviews", value: "4.8"),
                  _ProfileStat(label: "Completed", value: "18"),
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
          "3",
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
          "2",
          primaryColor,
        ),
        _buildStatCard(
          Icons.attach_money,
          "Total Revenue",
          "\$2,450",
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
<<<<<<< HEAD
=======
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
            child: const Text("Active", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
      _buildStatCard(Icons.calendar_today, "New Bookings", "3", onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VendorBottomNavScreen(initialIndex: 2),

          ),
        );
      }),
      _buildStatCard(Icons.star, "Pending Reviews", "2"),
      _buildStatCard(Icons.attach_money, "Total Revenue", "\$2,450"),
    ],
  );
}




 Widget _buildStatCard(IconData icon, String title, String value, {VoidCallback? onTap}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap, // Handle navigation when tapped
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: _boxDecoration(),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
>>>>>>> 3a50cd4eb048ffe8f41985af9a500b2ede661475
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
                onPressed: () {
                  setState(() {
                    services.removeAt(index);
                  });
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
          _buildContactItem(Icons.email, "contact@studiocreative.com"),
          const SizedBox(height: 12),
          _buildContactItem(Icons.phone, "+1 (555) 123-4567"),
          const SizedBox(height: 12),
          _buildContactItem(Icons.location_on, "123 Studio Lane, City, Country"),
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
        Text(
          text,
          style: const TextStyle(fontSize: 16),
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
<<<<<<< HEAD
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
=======
>>>>>>> 3a50cd4eb048ffe8f41985af9a500b2ede661475
}