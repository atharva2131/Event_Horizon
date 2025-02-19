import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, String>> paymentMethods = [
    {'type': 'Credit Card', 'details': '**** **** **** 1234'},
    {'type': 'PayPal', 'details': 'john.doe@gmail.com'},
    {'type': 'Bank Transfer', 'details': 'Account: ****5678'},
  ];

  void _addPaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature not implemented yet!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(paymentMethods[index]['type']!),
                      subtitle: Text(paymentMethods[index]['details']!),
                      trailing: const Icon(Icons.payment, color: Colors.green),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addPaymentMethod,
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}
