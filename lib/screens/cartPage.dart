import 'package:dominos/screens/userOrdersList.dart';
import 'package:dominos/screens/signup.dart'; // Import the signup page
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dominos/screens/provider.dart';
import 'cart.dart';
import '../services/firestore.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final fireStoreService = FireStoreService(); // Create an instance of FireStoreService

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Calculate total price
    double totalPrice = cart.items.values.fold(
      0,
          (previousValue, item) => previousValue + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Cart",
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(26.0),
        child: cart.items.isEmpty
            ? Center(child: Text('Cart is Empty')) // Display "Cart is Empty" text if cart is empty
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  var item = cart.items.values.toList()[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Rs. ${item.price}',
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add),
                              color: Colors.red,
                              onPressed: () {
                                // Increase quantity
                                cart.increaseQuantity(item.name);
                              },
                            ),
                            Text(
                              'Qty: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove),
                              color: Colors.red,
                              onPressed: () {
                                // Decrease quantity
                                cart.decreaseQuantity(item.name);
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            // Remove item
                            cart.removeItem(item.name);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'Total: Rs. $totalPrice',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = userProvider.email ?? '';
                String username = userProvider.username ?? '';

                // Check if username is set
                if (username.isNotEmpty) {
                  // Proceed with placing the order
                  // Fetch user document from Firestore
                  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(email)
                      .get();

                  // Extract phoneNumber and address from user document
                  String phoneNumber = userSnapshot['phoneNumber'] ?? '';
                  String address = userSnapshot['address'] ?? '';

                  // Check if phoneNumber and address are not null
                  if (phoneNumber.isNotEmpty && address.isNotEmpty) {
                    // Print the pending order details before sending it to Firestore
                    print('Pending Order Details:');
                    print('Username: $username');
                    print('Email: $email');
                    print('Phone Number: $phoneNumber');
                    print('Address: $address');
                    print('Total Price: $totalPrice');
                    print('Items:');
                    cart.items.forEach((key, item) {
                      print('${item.name}: Quantity: ${item.quantity}, Price: ${item.price}');
                    });

                    // Pass order details and user information to Firebase method using fireStoreService instance
                    fireStoreService.addPendingOrder(cart.items, totalPrice, username, email, phoneNumber, address);

                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Order'),
                          content: Text('Are you sure to confirm Order?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                // Dismiss dialog
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Dismiss dialog
                                Navigator.of(context).pop();
                                // Show snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Order Placed! please check for accept confirmation'),
                                  ),
                                );
                                cart.clearCart();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UserOrders()),
                                );
                              },
                              child: Text('Ok'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    print('Error: Phone number or address is empty');
                  }
                } else {
                  // Redirect to signup page and display a snackbar
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please sign up to place your order'),
                    ),
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0)),
              ),
              child: Text(
                'Confirm Order',
                style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
