import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetails extends StatefulWidget {
  final int orderId; // Add email as a parameter

  const OrderDetails({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailsFuture = _fetchOrderDetails();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchOrderDetails() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> orderSnapshot =
      await FirebaseFirestore.instance
          .collection('orders')
          .where('orderId', isEqualTo: widget.orderId)
          .get();

      if (orderSnapshot.docs.isNotEmpty) {
        // If there's a matching document, return the first one
        return orderSnapshot.docs.first;
      } else {
        // If no matching document found
        throw Exception('No order found with orderId: ${widget.orderId}');
      }
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Order Details',
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final orderData = snapshot.data!.data()!;
            // You can now use orderData to display order details
            return ListView(
              padding: EdgeInsets.all(20.0),
              children: [
                _buildDetail('Username', orderData['username']),
                _buildDetail('Email', orderData['email']),
                _buildDetail('Address', orderData['address']),
                _buildDetail('Phone Number', orderData['phoneNumber']),
                _buildDetail('Total Price Rs. ', orderData['totalPrice'].toString()),
                _buildDetail('Order Status', orderData['orderStatus']),
                SizedBox(height: 20),
                Text(
                  'Items:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Column(
                  children: (orderData['items'] as Map<String, dynamic>)
                      .entries
                      .map(
                        (entry) => ListTile(
                      title: Text(
                        entry.value['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Quantity: ${entry.value['quantity']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Text(
      '$label: $value',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
