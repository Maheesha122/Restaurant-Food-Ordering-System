import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dominos/services/firestore.dart';

class FavoritesPage extends StatelessWidget {
  final FireStoreService firestoreService = FireStoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Notes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
    );
  }
}
