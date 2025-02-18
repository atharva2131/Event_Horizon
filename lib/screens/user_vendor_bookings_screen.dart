import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VendorBookingsScreen extends StatelessWidget {
  const VendorBookingsScreen({super.key});

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
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
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
          ),
          
          // Filter Tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                _buildFilterButton("All Vendors", true),
                _buildFilterButton("DJ", false),
                _buildFilterButton("Photographer", false),
                _buildFilterButton("Caterer", false),
              ],
            ),
          ),

          // Location Filter
          Padding(
            padding: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.purple),
              title: const Text("New York, NY"),
              trailing: const Icon(FontAwesomeIcons.chevronRight, color: Colors.grey),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          // Sort By
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              title: const Text("Sort by: Recommended"),
              trailing: const Icon(FontAwesomeIcons.chevronRight, color: Colors.grey),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          // Vendor List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                _buildVendorCard(
                  "Elegant Moments Photography",
                  "Photographer",
                  "4.9 (128 reviews)",
                  "Manhattan, NY",
                  "https://storage.googleapis.com/a1aa/image/wj2LWZa-QvobUzODv2FzpYBOK1bgDkSUn300g0CoXBk.jpg",
                  featured: true,
                ),
                _buildVendorCard(
                  "Rhythm Masters DJ",
                  "DJ",
                  "4.8 (96 reviews)",
                  "Brooklyn, NY",
                  "https://storage.googleapis.com/a1aa/image/EFczGVqHFz21baVF823M33r3r4MhnR5DgWo2XRjcObM.jpg",
                ),
                _buildVendorCard(
                  "Divine Catering Co.",
                  "Caterer",
                  "4.7 (156 reviews)",
                  "Queens, NY",
                  "https://storage.googleapis.com/a1aa/image/wtVZIiH9vg9gurs00mtiFhnaNjz-lJCVBAwaqDwSjkM.jpg",
                  featured: true,
                ),
                _buildVendorCard(
                  "Blooming Bliss Florist",
                  "Florist",
                  "4.6 (84 reviews)",
                  "Manhattan, NY",
                  "https://storage.googleapis.com/a1aa/image/JpcT44qZj3e_Uts3KJ9W4-oIfN1_pzn4CzSRjCm3qHw.jpg",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.purple : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildVendorCard(
    String name,
    String category,
    String rating,
    String location,
    String imageUrl, {
    bool featured = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              if (featured)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Featured", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(category, style: TextStyle(color: Colors.grey[600])),
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.solidStar, size: 16, color: Colors.amber),
                    const Icon(FontAwesomeIcons.solidStar, size: 16, color: Colors.amber),
                    const Icon(FontAwesomeIcons.solidStar, size: 16, color: Colors.amber),
                    const Icon(FontAwesomeIcons.solidStar, size: 16, color: Colors.amber),
                    const Icon(FontAwesomeIcons.starHalfAlt, size: 16, color: Colors.amber),
                    const SizedBox(width: 5),
                    Text(rating, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.mapMarkerAlt, size: 14, color: Colors.purple),
                    const SizedBox(width: 5),
                    Text(location, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
