import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_details.dart'; // Import the order details page
import '../services/firestore.dart';

class OrderList extends StatefulWidget {
  final String orderStatus;

  const OrderList({Key? key, required this.orderStatus}) : super(key: key);

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late Future<List<DocumentSnapshot>> _ordersFuture;
  final FireStoreService _fireStoreService = FireStoreService();

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<DocumentSnapshot>> _fetchOrders() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderStatus', isEqualTo: widget.orderStatus)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPending = widget.orderStatus.contains('Pending');
    bool isAccepted = widget.orderStatus.contains('Accepted');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.orderStatus,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final orders = snapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index].data()! as Map<String, dynamic>;

                  return ListTile(
                    title: Text(
                      '${order['orderId']} - ${order['email']}',
                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),

                    trailing: isPending
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            _fireStoreService.updateAcceptedOrder(order['orderId']);
                          },
                          child: Text(
                            'Accept',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            _fireStoreService.updateCancelledOrder(order['orderId']);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    )
                        : isAccepted
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            _fireStoreService.updateCompletedOrder(order['orderId']);
                          },
                          child: Text(
                            'Complete',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            _fireStoreService.updateCancelledOrder(order['orderId']);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetails(orderId: order['orderId']),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
