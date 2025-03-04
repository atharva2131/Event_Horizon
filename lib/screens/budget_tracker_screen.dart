import 'package:flutter/material.dart';

class BudgetTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Budget Tracker',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // Add new expense functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Budget Overview Card
            _buildBudgetOverview(),

            SizedBox(height: 16),

            // Summary Section
            Row(
              children: [
                Expanded(child: _buildSummaryCard(Icons.access_time, "Total Expenses", "12")),
                SizedBox(width: 8),
                Expanded(child: _buildSummaryCard(Icons.category, "Categories", "6")),
              ],
            ),

            SizedBox(height: 16),

            // Recent Expenses List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recent Expenses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildExpenseItem(Icons.camera, "Photographer", "March 15, 2024", "\$2000"),
                        _buildExpenseItem(Icons.home, "Venue Deposit", "March 10, 2024", "\$3000"),
                        _buildExpenseItem(Icons.restaurant, "Catering Advance", "March 8, 2024", "\$1500"),
                        _buildExpenseItem(Icons.brush, "Decoration", "March 5, 2024", "\$300"),
                        _buildExpenseItem(Icons.music_note, "DJ Booking", "March 1, 2024", "\$200"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Budget Overview Widget
  Widget _buildBudgetOverview() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Budget", style: TextStyle(color: Colors.grey[600])),
                  Text("\$10,000", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              Icon(Icons.account_balance_wallet, size: 32, color: Colors.blue),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.7, // 70% spent
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 8,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Spent", style: TextStyle(color: Colors.grey[600])),
                  Text("\$7,000", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Remaining", style: TextStyle(color: Colors.grey[600])),
                  Text("\$3,000", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Summary Card Widget
  Widget _buildSummaryCard(IconData icon, String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: Colors.blue),
              SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Expense Item Widget
  Widget _buildExpenseItem(IconData icon, String title, String date, String amount) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(date, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          Text(amount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
