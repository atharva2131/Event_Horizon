import 'package:flutter/material.dart';
import 'SignInPage.dart'; // Import SignInPage
import 'package:eventhorizon/widgets/RoleCard.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // Prevents overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Heading Text
                  Text(
                    'Welcome to EventHorizon',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose your role to proceed',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // RoleCard 1: User
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: RoleCard(
                      icon: Icons.person,
                      color: Colors.blue[100]!,
                      iconColor: Colors.blue[600]!,
                      title: "I'm a User",
                      description:
                          "Browse products and services from verified vendors",
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
                    child: RoleCard(
                      icon: Icons.store,
                      color: Colors.purple[100]!,
                      iconColor: Colors.purple[600]!,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
  