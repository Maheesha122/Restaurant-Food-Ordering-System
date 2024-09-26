import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore.dart';

class ViewUsers extends StatefulWidget {
  const ViewUsers({Key? key}) : super(key: key);

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  final FireStoreService _fireStoreService = FireStoreService();

  late Future<List<Map<String, dynamic>>> _itemListFuture;

  @override
  void initState() {
    super.initState();
    _itemListFuture = _fetchItems();
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      return querySnapshot.docs.map((doc) {
        return {
          'email': doc['email'],
          'username': doc['username'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Users List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _itemListFuture,
          builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Display a loading indicator while waiting for data
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Display an error message if fetching data fails
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              // Display the list of items
              final itemList = snapshot.data!;
              return ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  final user = itemList[index];
                  return Card(
                    color: Color(0xffbeecfd),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ' ${user['username']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            ' ${user['email']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      onTap: () async {
                        // Handle onTap event
                      },
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
