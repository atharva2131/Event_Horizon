import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // Deep purple color theme
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple
  final Color lightPurple = const Color(0xFFD1C4E9); // Light Purple
  final Color accentColor = const Color(0xFF9575CD); // Medium Purple
  
  final TextEditingController _searchController = TextEditingController();
  int _expandedIndex = -1;
  
  final List<Map<String, String>> faq = [
    {
      'question': 'How to book an event?',
      'answer': 'To book an event, navigate to the Events section from the main menu. Browse through available events or use the search function to find a specific event. Once you\'ve found your preferred event, tap on it to view details and click the "Book Now" button. Follow the on-screen instructions to complete your booking.'
    },
    {
      'question': 'How to contact support?',
      'answer': 'There are several ways to contact our support team:\n\n1. Email us at support@eventhorizon.com\n2. Use the in-app chat feature available in the Help & Support section\n3. Call our customer service at +1 (555) 123-4567\n\nOur support team is available Monday through Friday, 9 AM to 6 PM EST.'
    },
    {
      'question': 'How to cancel a booking?',
      'answer': 'To cancel a booking, go to "My Events" in your profile and select the event you wish to cancel. Tap on "Cancel Booking" and follow the prompts. Please note that cancellation policies vary depending on the event and how close to the event date you are cancelling. Some events may offer partial or no refunds for late cancellations.'
    },
    {
      'question': 'What payment methods are accepted?',
      'answer': 'We accept various payment methods including credit/debit cards (Visa, MasterCard, American Express), PayPal, and bank transfers. You can manage your payment methods in the Account Settings section under "Payment Methods".'
    },
    {
      'question': 'How do I reset my password?',
      'answer': 'To reset your password, tap on "Forgot Password" on the login screen. Enter the email address associated with your account, and we\'ll send you a password reset link. Follow the instructions in the email to create a new password.'
    },
    {
      'question': 'Are there any booking fees?',
      'answer': 'Yes, a small service fee is applied to bookings to cover processing costs. The exact fee amount will be displayed during checkout before you confirm your booking.'
    },
  ];
  
  List<Map<String, String>> filteredFaq = [];
  
  @override
  void initState() {
    super.initState();
    filteredFaq = List.from(faq);
    _searchController.addListener(_filterFaq);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterFaq() {
    if (_searchController.text.isEmpty) {
      setState(() {
        filteredFaq = List.from(faq);
      });
    } else {
      setState(() {
        filteredFaq = faq
            .where((item) => item['question']!
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
                item['answer']!
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    }
  }
  
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@eventhorizon.com',
      query: 'subject=Support Request&body=Hello, I need assistance with...',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
    }
  }
  
  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Support options section
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              children: [
                Text(
                  'How can we help you?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for help',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSupportOption(
                        icon: Icons.email,
                        title: 'Email Us',
                        onTap: _launchEmail,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSupportOption(
                        icon: Icons.phone,
                        title: 'Call Us',
                        onTap: _launchPhone,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSupportOption(
                        icon: Icons.chat_bubble,
                        title: 'Live Chat',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Live chat is not available in this demo'),
                              backgroundColor: primaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // FAQ section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filteredFaq.length} results',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: filteredFaq.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFaq.length,
                    itemBuilder: (context, index) {
                      return _buildFaqItem(index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 70,
            color: lightPurple,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or browse all FAQs',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            icon: Icon(Icons.refresh, color: primaryColor),
            label: Text(
              'Reset Search',
              style: TextStyle(color: primaryColor),
            ),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFaqItem(int index) {
    final isExpanded = _expandedIndex == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedIndex = expanded ? index : -1;
            });
          },
          title: Text(
            filteredFaq[index]['question']!,
            style: TextStyle(
              fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
              color: isExpanded ? primaryColor : Colors.black87,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isExpanded ? primaryColor : lightPurple.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.question_answer,
              color: isExpanded ? Colors.white : primaryColor,
              size: 20,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isExpanded ? primaryColor.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isExpanded ? primaryColor : Colors.grey,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                filteredFaq[index]['answer']!,
                style: TextStyle(
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.thumb_up, size: 16),
                    label: const Text('Helpful'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Thank you for your feedback!'),
                          backgroundColor: primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.thumb_down, size: 16),
                    label: const Text('Not Helpful'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('We\'ll improve this answer. Thank you!'),
                          backgroundColor: primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
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

