import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:eventhorizon/screens/user_messages_screen.dart'; // Import the ChatListScreen

class VendorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  // Define theme colors
  static const Color primaryColor = Colors.deepPurple;
  static const Color lightPurple = Color(0xFFD1C4E9); // Deep Purple 100
  static const Color backgroundColor = Colors.white;
  static const Color textOnPurple = Colors.white;
  static const Color textOnWhite = Color(0xFF311B92); // Deep Purple 900

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVendorInfo(context),
                _buildDescription(),
                _buildGallery(),
                const SizedBox(height: 20),
                _buildBookNowButton(context),
                const SizedBox(height: 30), // Extra padding at bottom
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🖼️ **Sliver App Bar with Banner Image**
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner image
            Image.network(
              vendor["imageUrl"],
              fit: BoxFit.cover,
            ),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            // Category badge
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vendor["category"],
                  style: const TextStyle(
                    color: textOnPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ℹ️ **Vendor Info Section**
  Widget _buildVendorInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor["name"],
                  style: const TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: textOnWhite,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      vendor["rating"],
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.mapMarkerAlt, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      vendor["location"],
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Message Button
          _buildMessageButton(context),
        ],
      ),
    );
  }

  /// ✉️ **Message Button (Navigates to Chat List)**
  Widget _buildMessageButton(BuildContext context) {
    return ElevatedButton(
      key: const Key('messageButton'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatListScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textOnPurple,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        elevation: 3,
      ),
      child: const Icon(FontAwesomeIcons.commentDots, size: 20),
    );
  }

  /// 📝 **Vendor Description**
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lightPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      FontAwesomeIcons.infoCircle, 
                      color: primaryColor, 
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "About Vendor",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: textOnWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "${vendor["name"]} is a top-rated service provider known for excellence and professionalism. With years of experience in the industry, they deliver exceptional service tailored to your specific needs and preferences.",
                style: TextStyle(
                  fontSize: 15, 
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  FontAwesomeIcons.images, 
                  color: primaryColor, 
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Gallery",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: textOnWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      images[index], 
                      width: 140, 
                      height: 140, 
                      fit: BoxFit.cover,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          key: const Key('bookNowButton'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Booking Confirmed!",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: primaryColor,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: textOnPurple,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.calendarCheck, size: 18),
              SizedBox(width: 12),
              Text(
                "Book Now",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

