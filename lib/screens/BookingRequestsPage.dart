import 'package:flutter/material.dart';

class BookingRequestsPage extends StatefulWidget {
  final String name;
  final String service;
  final String schedule;
  final String location;
  final String price;
  final String imageUrl;

  const BookingRequestsPage({
    super.key,
    required this.name,
    required this.service,
    required this.schedule,
    required this.location,
    required this.price,
    required this.imageUrl,
  });

  @override
  _BookingRequestsPageState createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  // List to hold all booking requests
  List<Map<String, String>> requests = [];

  @override
  void initState() {
    super.initState();
    // Initializing the requests list with the provided request
    requests.add({
      'name': widget.name,
      'service': widget.service,
      'schedule': widget.schedule,
      'location': widget.location,
      'price': widget.price,
      'imageUrl': widget.imageUrl,
    });
  }

  // Method to delete the request
  void _rejectRequest(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("Do you want to reject this booking?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                requests.removeAt(index); // Remove the request at the given index
              });
              Navigator.pop(context); // Close the dialog after deletion
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  // Method to accept the request (could navigate or process further)
  void _acceptRequest() {
    // You can add accept functionality here, like navigating to another page
    // For now, it will just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request Accepted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Booking Requests')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (requests.isNotEmpty)
              _buildNewRequest(requests[0], 0), // Display the first request
            const SizedBox(height: 20),
            const Text('Previous Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // You can display previous requests below
          ],
        ),
      ),
    );
  }

  Widget _buildNewRequest(Map<String, String> request, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(request['imageUrl']!),
                  radius: 24,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(request['service']!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(request['schedule']!, style: const TextStyle(color: Colors.grey)),
            Text(request['location']!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(request['price']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _acceptRequest,
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: () => _rejectRequest(index), // Pass the index for rejection
                    child: const Text('Reject', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
