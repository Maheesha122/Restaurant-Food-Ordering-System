import 'package:dominos/admin/viewUsers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/provider.dart';
import '../screens/signup.dart';
import 'manageItems.dart';
import 'manage_orders.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.username ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Home",
          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
            children: [
              SizedBox(height: 15.0,),

              Text(
                " ${username ?? ''}", // Replace "User" with the actual username
                style: TextStyle(color: Colors.red, fontSize: 23, fontWeight:FontWeight.w600),
              ),
              SizedBox(height: 15.0,),
              ListTile(

                leading: Icon(Icons.library_add_check, color: Colors.blue[900]),
                title: Text(
                  "Manage Orders",
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight:FontWeight.w600),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageOrders()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.manage_search, color: Colors.blue[900]),
                title: Text(
                  "Manage Items",
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageItems()),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.people, color: Colors.blue[900]),
                title: Text(
                  "View Users",
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewUsers()),
                  );
                },
              ),
              SizedBox(height: 55.0,),
              ElevatedButton(
                onPressed: () {
                  Provider.of<UserProvider>(context, listen: false).clearUser();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // background color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
