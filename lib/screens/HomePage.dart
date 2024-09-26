import 'package:flutter/material.dart';
import 'cartPage.dart';
import 'menuPage.dart';
import 'provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override

  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.username ?? ', Welcome to FoodiePot!';
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 380,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/home_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, bottom: 30),
                  child: Text(
                    "Hi ${username ?? ''}", // Replace "User" with the actual username
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(26),
              child: Column(
                children: [
                  _buildRow(context, 'assets/c1.png', 'Delux Burger', 'Tate of home', '/chicken'),
                  SizedBox(height: 16),
                  _buildRow(context, 'assets/c2.png', 'Chicken Delight', 'Eating Well', '/beef'),
                  SizedBox(height: 16),
                  _buildRow(context, 'assets/c3.png', 'BoBo Joy', 'Traditional boba pearls', '/vegetables'),
                  SizedBox(height: 16),
                  _buildRow(context, 'assets/c4.png', 'Desserts', 'Celebreating Sweets', '/desserts'),
                  SizedBox(height: 26),
                  Text(
                    'Deals and Promotions',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 26),

                  Container(
                    width: 400,
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.0),
                      image: DecorationImage(
                        image: AssetImage('assets/offer1.jpg'),
                        fit: BoxFit.fitWidth,                      ),
                    ),
                  ),
                  SizedBox (height:20.0),
                  Container(
                    width: 400,
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.0),
                      image: DecorationImage(
                        image: AssetImage('assets/offer2.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to cart page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartPage()),
          );
        },
        backgroundColor: Colors.redAccent,
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String imagePath, String title, String subtitle, String routeName) {
    return GestureDetector(
      onTap: () {
        // Navigate to MenuScreen and select the relevant tab based on the category
        int tabIndex;
        switch (routeName) {
          case '/chicken':
            tabIndex = 1; // Index of Delux Burger tab
            break;
          case '/beef':
            tabIndex = 2; // Index of Chicken Delight tab
            break;
          case '/vegetables':
            tabIndex = 3; // Index of BoBo Joy tab
            break;
          case '/desserts':
            tabIndex = 4; // Index of Ice Cream tab
            break;
          default:
            tabIndex = 0; // Index of All tab
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen(initialTabIndex: tabIndex)),
        );
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
