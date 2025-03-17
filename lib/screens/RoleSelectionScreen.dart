import 'package:flutter/material.dart';
import 'SignInPage.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  // Define theme colors
  static const Color primaryColor = Color(0xFF673AB7); // Deep Purple 500
  static const Color lightPurple = Color(0xFFD1C4E9); // Deep Purple 100
  static const Color darkPurple = Color(0xFF4527A0); // Deep Purple 800
  static const Color backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // Prevents overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event,
                      size: 40,
                      color: primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Heading Text
                  const Text(
                    'Welcome to EventHorizon',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose your role to proceed',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // RoleCard 1: User
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildRoleCard(
                      context: context,
                      icon: Icons.person,
                      color: lightPurple,
                      iconColor: primaryColor,
                      title: "I'm a User",
                      description: "Browse products and services from verified vendors",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(isUser: true),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // RoleCard 2: Vendor
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildRoleCard(
                      context: context,
                      icon: Icons.store,
                      color: darkPurple,
                      iconColor: Colors.white,
                      title: "I'm a Vendor",
                      description: "Sell your products and services to customers",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(isUser: false),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Admin card removed
                  
                  const SizedBox(height: 24),
                  
                  // Footer text
                  const Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

