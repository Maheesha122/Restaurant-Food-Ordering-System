import 'package:dominos/screens/provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../admin/order_details.dart'; // Import the OrderDetails page

class UserOrders extends StatefulWidget {
  const UserOrders({Key? key}) : super(key: key);

  @override
  State<UserOrders> createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  late String _email; // Variable to store email from the provider

  @override
  void initState() {
    super.initState();
    _getEmailFromProvider(); // Initialize the email from the provider
  }

  // Function to get email from the provider
  void _getEmailFromProvider() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _email = userProvider.email ?? ''; // Handle null email
  }

  Future<List<Map<String, dynamic>>> _fetchUserOrders() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('orders')
          .where('email', isEqualTo: _email) // Filter based on provider's email
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'orderId': doc['orderId'], // Get orderId from document id
          'orderStatus': doc['orderStatus'] ?? 'No Status', // Add default value for order status
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'My Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        color: Colors.yellow, // Set the background color to yellow
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchUserOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Map<String, dynamic>> orders = snapshot.data!;
              orders.sort((a, b) {
                // Define the order of statuses
                Map<String, int> statusOrder = {
                  'Pending': 0,
                  'Accepted': 1,
                  'Completed': 2,
                  'Cancelled': 3,
                };
                return statusOrder[a['orderStatus']]! - statusOrder[b['orderStatus']]!;
              });
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          'Order ID: ${order['orderId']}',
                        ),
                        subtitle: Text(
                          'Order Status: ${order['orderStatus']}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetails(orderId: order['orderId']),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
