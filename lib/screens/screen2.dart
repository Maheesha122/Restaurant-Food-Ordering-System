import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dominos/services/firestore.dart';

import 'favorites.dart';


class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<SecondScreen> {
  final FireStoreService firestoreService = FireStoreService();
  final TextEditingController textController = TextEditingController();
  final TextEditingController subtextController = TextEditingController();
  late Stream<QuerySnapshot> _notesStream;
  String _searchText = '';
  bool _ascendingOrder = true;
  bool _isDarkMode = false;
  bool _showFavorites = false; // Track whether to show favorites

  @override
  void initState() {
    super.initState();
    _notesStream = firestoreService.getNotesStream();
  }

  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Main Text',
              ),
            ),
            TextField(
              controller: subtextController,
              decoration: InputDecoration(
                labelText: 'Subtext',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                firestoreService.addNote(
                  textController.text,
                  subtextController.text,
                );
                Fluttertoast.showToast(
                  msg: "Note added successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
              } else {
                firestoreService.updateNote(
                  docID,
                  textController.text,
                  subtextController.text,
                );
              }
              textController.clear();
              subtextController.clear();
              Navigator.pop(context);
            },
            child: Text("Add Note"),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Search',
        hintText: 'Search notes...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  void _showFavoriteNotes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Favorite Notes'),
        content: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getFavoriteNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = notesList[index];
                  String noteText = document['note'];
                  String subtext = document['subtext'] ?? '';

                  return ListTile(
                    title: Text(noteText),
                    subtitle: subtext.isNotEmpty ? Text(subtext) : null,
                    onTap: () {
                      // Handle onTap action if needed
                    },
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Taking Notes"),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _ascendingOrder = !_ascendingOrder;
                });
              },
              icon: Icon(_ascendingOrder ? Icons.arrow_upward : Icons.arrow_downward),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage()), // Navigate to FavoritesPage
                );
              },
              icon: Icon(Icons.favorite), // Use your favorite icon here
            ),


          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: openNoteBox,
          child: Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: _buildSearchBar(),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _notesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List notesList = snapshot.data!.docs;
                    if (_searchText.isNotEmpty) {
                      notesList = notesList.where((note) {
                        final String noteText = note['note'];
                        return noteText.toLowerCase().contains(_searchText.toLowerCase());
                      }).toList();
                    }
                    if (!_ascendingOrder) {
                      notesList = notesList.reversed.toList();
                    }
                    return ListView.builder(
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = notesList[index];
                        String docID = document.id;

                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String noteText = data['note'];
                        String subtext = data['subtext'] ?? '';
                        bool isFavorite = data['favorite'] ?? false; // Check if the note is marked as favorite

                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                noteText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                subtext,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => openNoteBox(docID: docID),
                                icon: Icon(Icons.settings),
                              ),
                              IconButton(
                                onPressed: () {
                                  _confirmDelete(context, docID, isFavorite); // Pass isFavorite to _confirmDelete
                                },
                                icon: Icon(Icons.delete),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Toggle favorite status when the favorite icon is clicked
                                  firestoreService.toggleFavorite(docID, !isFavorite);
                                },
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No Notes!"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String docID, bool isFavorite) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this note?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                firestoreService.deleteNote(docID);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}