import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart.dart';
import 'cartPage.dart';
import 'item_model.dart';

class DescriptionPage extends StatefulWidget {
  final String itemName;
  final double itemPrice;
  final String itemDescription;
  final String imageUrl;

  const DescriptionPage({
    Key? key,
    required this.itemName,
    required this.itemPrice,
    required this.itemDescription,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<DescriptionPage> createState() => _ItemDescriptionPageState();
}

class _ItemDescriptionPageState extends State<DescriptionPage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Remove the title text from the app bar
        title: Container(), // Empty container to remove title
        // Keep the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the image with background image
            Stack(
              children: [
                // Background container with background image
                Container(
                  height: 200,
                  width: double.infinity, // Take full width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage('assets/image background.png'), // Background image
                      fit: BoxFit.fitHeight, // Cover the entire container
                    ),
                  ),
                ),
                // Original image
                Positioned.fill(
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Display the item name
            Text(
              widget.itemName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),
            // Display the item description
            Text(
              widget.itemDescription,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 20),
            // Display the item price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Price:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Rs ${widget.itemPrice.toStringAsFixed(2)}', // Convert double to string
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0,),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Item item = Item(
                    name: widget.itemName,
                    price: widget.itemPrice,
                    imageUrl: widget.imageUrl,
                    quantity: 1,
                  );
                  Provider.of<Cart>(context, listen: false).addItem(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Item Added to cart"))
                  );                  // Add item to cart
                },

                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xff09b556)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(15.0)),
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartPage()),
          );
        },
        backgroundColor:Colors.redAccent,
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
      ),
    );
  }
}
