import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'User_vendor_detail_screen.dart';

class VendorBookingsScreen extends StatefulWidget {
  const VendorBookingsScreen({super.key});

  @override
  State<VendorBookingsScreen> createState() => _VendorBookingsScreenState();
}

class _VendorBookingsScreenState extends State<VendorBookingsScreen> {
  String selectedFilter = "All Vendors";
  final List<String> filters = ["All Vendors", "DJ", "Photographer", "Caterer", "Florist"];

  final List<Map<String, dynamic>> vendors = [
    {
      "name": "Elegant Moments Photography",
      "category": "Photographer",
      "rating": "4.9 (128 reviews)",
      "location": "Manhattan, NY",
      "imageUrl": "https://storage.googleapis.com/a1aa/image/wj2LWZa-QvobUzODv2FzpYBOK1bgDkSUn300g0CoXBk.jpg",
    },
    {
      "name": "Rhythm Masters DJ",
      "category": "DJ",
      "rating": "4.8 (96 reviews)",
      "location": "Brooklyn, NY",
      "imageUrl": "https://storage.googleapis.com/a1aa/image/EFczGVqHFz21baVF823M33r3r4MhnR5DgWo2XRjcObM.jpg",
    },
    {
      "name": "Divine Catering Co.",
      "category": "Caterer",
      "rating": "4.7 (156 reviews)",
      "location": "Queens, NY",
      "imageUrl": "https://storage.googleapis.com/a1aa/image/wtVZIiH9vg9gurs00mtiFhnaNjz-lJCVBAwaqDwSjkM.jpg",
    },
  ];

  // Define theme colors
  final Color primaryColor = Colors.deepPurple;
  final Color lightPurple = Colors.deepPurple.shade100;
  final Color backgroundColor = Colors.white;
  final Color textOnPurple = Colors.white;
  final Color textOnWhite = Colors.deepPurple.shade900;

  List<Map<String, dynamic>> get filteredVendors {
    if (selectedFilter == "All Vendors") {
      return vendors;
    }
    return vendors.where((vendor) => vendor["category"] == selectedFilter).toList();
  }

  void _setFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.chevronLeft, color: textOnPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Find Vendors", style: TextStyle(color: textOnPurple, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          Expanded(child: _buildVendorList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(FontAwesomeIcons.search, color: Colors.grey),
          hintText: "Search vendors...",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) => _buildFilterButton(filter)).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    final isSelected = selectedFilter == text;
    
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () => _setFilter(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? primaryColor : Colors.white,
          foregroundColor: isSelected ? textOnPurple : primaryColor,
          elevation: isSelected ? 2 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.transparent : primaryColor,
              width: 1,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildVendorList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredVendors.length,
      itemBuilder: (context, index) {
        final vendor = filteredVendors[index];
        return _buildVendorCard(vendor);
      },
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorDetailScreen(vendor: vendor),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    vendor["imageUrl"], 
                    height: 200, 
                    width: double.infinity, 
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vendor["category"],
                      style: TextStyle(
                        color: textOnPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor["name"],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textOnWhite,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        vendor["rating"],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: primaryColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        vendor["location"],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

