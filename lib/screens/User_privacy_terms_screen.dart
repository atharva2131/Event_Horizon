import 'package:flutter/material.dart';

class PrivacyTermsScreen extends StatefulWidget {
  const PrivacyTermsScreen({super.key});

  @override
  _PrivacyTermsScreenState createState() => _PrivacyTermsScreenState();
}

class _PrivacyTermsScreenState extends State<PrivacyTermsScreen> with SingleTickerProviderStateMixin {
  // Deep purple color theme
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple
  final Color lightPurple = const Color(0xFFD1C4E9); // Light Purple
  final Color accentColor = const Color(0xFF9575CD); // Medium Purple
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Privacy & Terms', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Privacy Policy'),
            Tab(text: 'Terms of Service'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Privacy Policy Tab
          _buildPrivacyPolicyTab(),
          
          // Terms of Service Tab
          _buildTermsOfServiceTab(),
        ],
      ),
    );
  }
  
  Widget _buildPrivacyPolicyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: lightPurple.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.privacy_tip,
                size: 40,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          Center(
            child: Text(
              'Last updated: March 1, 2024',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildPolicySection(
            title: 'Information We Collect',
            content: 'We collect information you provide directly to us, such as when you create or modify your account, request on-demand services, contact customer support, or otherwise communicate with us. This information may include: name, email, phone number, postal address, profile picture, payment method, items requested, delivery notes, and other information you choose to provide.',
          ),
          _buildPolicySection(
            title: 'How We Use Your Information',
            content: 'We may use the information we collect about you to:\n\n• Provide, maintain, and improve our Services\n• Process and complete transactions, and send related information\n• Send transactional messages\n• Connect users requesting services with users providing services\n• Send administrative messages\n• Facilitate contests and promotions\n• Personalize and improve the Services\n• Monitor and analyze trends, usage, and activities in connection with our Services',
          ),
          _buildPolicySection(
            title: 'Sharing of Information',
            content: 'We will not share your personal data without your consent. Your information is protected under our strict data policies. We may share your information with third-party service providers who perform services on our behalf, such as payment processing, data analysis, email delivery, hosting services, customer service, and marketing assistance.',
          ),
          _buildPolicySection(
            title: 'Your Choices',
            content: 'Account Information: You may update, correct, or delete information about you at any time by logging into your online account or by emailing us. If you wish to delete or deactivate your account, please email us, but note that we may retain certain information as required by law or for legitimate business purposes.',
          ),
          _buildPolicySection(
            title: 'Contact Us',
            content: 'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@eventhorizon.com\nPhone: +1 (555) 123-4567\nAddress: 123 Main Street, Suite 456, New York, NY 10001',
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download Full Privacy Policy'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Download started'),
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
    );
  }
  
  Widget _buildTermsOfServiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: lightPurple.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gavel,
                size: 40,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          Center(
            child: Text(
              'Last updated: March 1, 2024',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildPolicySection(
            title: 'Acceptance of Terms',
            content: 'By accessing or using our Services, you agree to be bound by these Terms. If you do not agree to these Terms, you may not access or use the Services.',
          ),
          _buildPolicySection(
            title: 'User Accounts',
            content: 'To use our Services, you may need to create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to provide accurate and complete information when creating your account and to update your information to keep it accurate and complete.',
          ),
          _buildPolicySection(
            title: 'User Conduct',
            content: 'You agree not to engage in any of the following prohibited activities:\n\n• Copying, distributing, or disclosing any part of the Services\n• Using any automated system to access the Services\n• Attempting to interfere with the proper working of the Services\n• Bypassing measures we may use to prevent or restrict access to the Services\n• Misuse of the platform may result in account suspension',
          ),
          _buildPolicySection(
            title: 'Intellectual Property',
            content: 'The Services and its original content, features, and functionality are and will remain the exclusive property of our company and its licensors. The Services are protected by copyright, trademark, and other laws of both the United States and foreign countries.',
          ),
          _buildPolicySection(
            title: 'Termination',
            content: 'We may terminate or suspend your account and bar access to the Services immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation, including but not limited to a breach of the Terms.',
          ),
          _buildPolicySection(
            title: 'Limitation of Liability',
            content: 'In no event shall our company, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Services.',
          ),
          _buildPolicySection(
            title: 'Changes to Terms',
            content: 'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material we will provide at least 30 days\' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.',
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download Full Terms of Service'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Download started'),
                    backgroundColor: primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: primaryColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Have questions about our Terms?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Contact our legal team for clarification',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Contact feature not implemented in this demo'),
                        backgroundColor: primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Text(
                    'Contact',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPolicySection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Icon(Icons.article, color: primaryColor),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

