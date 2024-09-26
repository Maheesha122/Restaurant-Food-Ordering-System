import 'package:dominos/screens/signup.dart';
import 'package:dominos/screens/userOrdersList.dart';
import 'package:dominos/screens/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'aboutUs.dart';
import 'home.dart';
import 'provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'More',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.deepOrange),
                  title: Text(
                    'My Profile',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserProfile()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.shopping_bag, color: Colors.deepOrange),
                  title: Text(
                    'My Orders',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserOrders()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.deepOrange),
                  title: Text(
                    'Notifications',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onTap: () {},
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.deepOrange),
                  title: Text(
                    'About Us',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUs()),
                    );
                  },
                ),
                Divider(),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.username != null && userProvider.email != null) {
                      // If username and email are set, display Sign Out ListTile
                      return ListTile(
                        leading: Icon(Icons.logout, color: Colors.deepOrange),
                        title: Text(
                          'Sign Out',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        onTap: () {
                          userProvider.clearUser(); // Clear user data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                      );
                    } else {
                      // If username and email are not set, display Sign In TextTile
                      return ListTile(
                        leading: Icon(Icons.login, color: Colors.deepOrange),
                        title: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationPage(),
                            ),
                          );
                          // Navigate to sign in page
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
