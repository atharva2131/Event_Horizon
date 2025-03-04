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
          title: const Text("Add New Service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Service Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Service Price",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addNewService,
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
          title: const Text("Edit Service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "Service Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: "Service Price",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  services[index]["title"] = _titleController.text;
                  services[index]["price"] = _priceController.text;
                });
                Navigator.pop(context);
              },
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
      appBar: AppBar(
        title: const Text("Vendor Dashboard"),
        backgroundColor: Colors.blue,
        actions: const [Icon(Icons.more_vert, color: Colors.white)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildStatsGrid(context),
            const SizedBox(height: 16),
            _buildServicesSection(),
            const SizedBox(height: 16),
            _buildPortfolioSection(),
            const SizedBox(height: 16),
            _buildContactInfo(),
          ],
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              "https://storage.googleapis.com/a1aa/image/Pb6FWzcRzBLYGzQ40URCBIxsSIr4ZsbQaHF0_hv9KDw.jpg",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Studio Creative", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < 4 ? Icons.star : Icons.star_half,
                      color: Colors.yellow[700],
                      size: 18,
                    );
                  }),
                ),
                const Text("Professional Photography", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const vendorBookings.VendorBookingsScreen()),
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
        ),
      ),
    ),
  );
}


  Widget _buildServicesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Services", _isEditing ? "Done" : "Edit"),
          if (_isEditing)
            ...List.generate(services.length, (index) {
              return _buildEditableServiceItem(index);
            }),
          if (!_isEditing)
            ...List.generate(services.length, (index) {
              return _buildServiceItem(index);
            }),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showAddServiceModal,
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: const Text("+ Add New Service", style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableServiceItem(int index) {
    final service = services[index];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(service["price"], style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(service["price"], style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Switch(
            value: service["isActive"],
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
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Portfolio", ""),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: const Text("Add New Photo", style: TextStyle(color: Colors.blue)),
            ),
          ),
          const SizedBox(height: 8),
          portfolioImages.isEmpty
              ? const Text("No photos added yet.")
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                  itemCount: portfolioImages.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Contact Information", ""),
          _buildContactItem(Icons.email, "contact@studiocreative.com"),
          _buildContactItem(Icons.phone, "+1 (555) 123-4567"),
          _buildContactItem(Icons.location_on, "123 Studio Lane, City, Country"),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        if (actionText.isNotEmpty)
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(actionText),
          ),
      ],
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 2, blurRadius: 5),
      ],
    );
  }
}
