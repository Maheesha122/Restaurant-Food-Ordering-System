import 'package:flutter/material.dart';
import 'order_list.dart'; // Import the "order_list" page

class ManageOrders extends StatefulWidget {
  const ManageOrders({Key? key}) : super(key: key);

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Orders',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue[800]
      ),
      body: ListView(
        children: [
          SizedBox(height: 25.0),
          _buildOrderCard('Pending Orders', 'Pending'),
          _buildOrderCard('Accepted Orders', 'Accepted'),
          _buildOrderCard('Completed Orders', 'Completed'),
          _buildOrderCard('Cancelled Orders', 'Cancelled'),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildOrderCard(String title, String orderStatus) {
    return Card(
      color: Colors.yellow[500],
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderList(orderStatus: orderStatus),
            ),
          );
        },
      ),
    );
  }
}
