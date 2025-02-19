import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VendorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(vendor["name"], style: const TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerImage(),
            _buildVendorInfo(context), // ✅ Message button inside Vendor Info
            _buildDescription(),
            _buildGallery(),
            const SizedBox(height: 20),
            _buildBookNowButton(context),
          ],
        ),
      ),
    );
  }

  /// 🖼️ **Main Banner Image**
  Widget _buildBannerImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      child: Image.network(
        vendor["imageUrl"],
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      ),
    );
  }

  /// ℹ️ **Vendor Info Section (Now includes Message Button)**
  Widget _buildVendorInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vendor Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor["name"],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "${vendor["category"]} • ${vendor["rating"]}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.purple, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      vendor["location"],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Smaller Message Button (Aligned Right)
          _buildMessageButton(context),
        ],
      ),
    );
  }

  /// ✉️ **Smaller Message Button (Moved to Vendor Info, Right Aligned)**
  Widget _buildMessageButton(BuildContext context) {
    return ElevatedButton(
      key: const Key('messageButton'),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opening Chat..."), duration: Duration(seconds: 1)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Smaller button
        elevation: 3,
      ),
      child: const Icon(FontAwesomeIcons.commentDots, size: 16, color: Colors.white), // Small icon only
    );
  }

  /// 📝 **Vendor Description**
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade200, Colors.purple.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "About Vendor",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  " ${vendor["name"]} is a top-rated service provider, known for excellence and professionalism. "
                  "We offer premium services with outstanding customer satisfaction.",
                  style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🖼️ **Vendor Gallery**
  Widget _buildGallery() {
    final List<String> images = [
      vendor["imageUrl"],
      "https://storage.googleapis.com/a1aa/image/extra1.jpg",
      "https://storage.googleapis.com/a1aa/image/extra2.jpg",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gallery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(images[index], width: 120, height: 120, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **Book Now Button**
  Widget _buildBookNowButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          key: const Key('bookNowButton'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Booking Confirmed!"), duration: Duration(seconds: 1)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("Book Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
