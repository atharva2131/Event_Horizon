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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Find Vendors", style: TextStyle(color: Colors.black)),
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(FontAwesomeIcons.search, color: Colors.grey),
          hintText: "Search vendors...",
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: filters.map((filter) => _buildFilterButton(filter)).toList(),
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () => _setFilter(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedFilter == text ? Colors.purple : Colors.grey[300],
          foregroundColor: selectedFilter == text ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildVendorList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
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
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(vendor["imageUrl"], height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            ListTile(
              title: Text(vendor["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text("${vendor["category"]} • ${vendor["rating"]}"),
              trailing: Text(vendor["location"]),
            ),
          ],
        ),
      ),
    );
  }
}
