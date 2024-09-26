import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../screens/item_model.dart';

class FireStoreService {
  // Collection reference for 'notes' collection
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');
  final CollectionReference items = FirebaseFirestore.instance.collection('items');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://foodie-pot.appspot.com',
  );

  // Method to add a new note to Firestore
  Future<void> addNote(String note, String subnote) {
    // Add a new document to the 'notes' collection with note content and timestamp
    return notes.add({
      'note': note,
      'subtext': subnote, // Initialize subtext field with an empty string
      'timestamp': Timestamp.now(),
      'favorite': false, // Initialize favorite field as false
    });
  }

  // Method to add a new note to Firestore
  Future<void> addItem(int itemId, String categoryName, String itemName, String itemDescription, double itemPrice, String ImageUrl) {
    // Set the document ID to itemId while adding a new document
    return FirebaseFirestore.instance.collection('items').doc(itemId.toString()).set({
      'itemId': itemId,
      'categoryName': categoryName,
      'itemName': itemName,
      'itemDescription':itemDescription,
      'itemPrice':itemPrice,
      'imageUrl':ImageUrl,
    });
  }

  Future<void> addPendingOrder(Map<String, Item> items, double totalPrice, String username, String email, String phoneNumber, String address) async {
    try {
      // Get the latest order ID from Firestore
      int latestOrderId = await _getLatestOrderId();

      // Generate the next order ID
      int orderId = latestOrderId + 1;

      // Create a reference to the pendingOrders collection
      CollectionReference orders = FirebaseFirestore.instance.collection('orders');

      // Set the orderId as the document ID
      DocumentReference orderRef = orders.doc(orderId.toString());

      // Store the order data in the document
      await orderRef.set({
        'orderId': orderId,
        'email': email,
        'username': username,
        'address': address,
        'phoneNumber': phoneNumber,
        'totalPrice': totalPrice,
        'orderStatus': "Pending",
        'items': items.map((key, item) => MapEntry(key, {
          'name': item.name,
          'quantity': item.quantity,
        })),
        'timestamp': DateTime.now(),
      });

      print('Order added with ID: $orderId');
    } catch (e) {
      print('Error adding order: $e');
    }
  }

  Future<int> _getLatestOrderId() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').orderBy('orderId', descending: true).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['orderId'];
      } else {
        return 0; // If no orders found, start from 0
      }
    } catch (e) {
      print('Error getting latest order ID: $e');
      return 0; // Return 0 if error occurs
    }
  }


  Future<void> updateAcceptedOrder(int orderId) async {
    try {
      // Query to find the document with matching orderId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).limit(1).get();

      // Check if a document with the specified orderId exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get a reference to the document
        DocumentReference orderRef = querySnapshot.docs.first.reference;

        // Update the order status to "Accepted"
        await orderRef.update({
          'orderStatus': 'Accepted',
        });

        print('Order status updated successfully for id: $orderId');
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> updateCancelledOrder(int orderId) async {
    try {
      // Query to find the document with matching orderId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).limit(1).get();

      // Check if a document with the specified orderId exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get a reference to the document
        DocumentReference orderRef = querySnapshot.docs.first.reference;

        // Update the order status to "Cancelled"
        await orderRef.update({
          'orderStatus': 'Cancelled',
        });

        print('Order status updated successfully for id: $orderId');
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }


  Future<void> updateCompletedOrder(int orderId) async {
    try {
      // Query to find the document with matching orderId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).limit(1).get();

      // Check if a document with the specified orderId exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get a reference to the document
        DocumentReference orderRef = querySnapshot.docs.first.reference;

        // Update the order status to "Cancelled"
        await orderRef.update({
          'orderStatus': 'Completed',
        });

        print('Order status updated successfully for id: $orderId');
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  // Method to retrieve notes from Firestore as a stream
  Stream<QuerySnapshot> getNotesStream() {
    // Stream of snapshots from 'notes' collection ordered by timestamp in descending order
    final notesStream = notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  Stream<QuerySnapshot> getItemsStream() {
    // Stream of snapshots from 'notes' collection ordered by timestamp in descending order
    final itemsStream = items.orderBy('itemId', descending: true).snapshots();
    return itemsStream;
  }

  Stream<QuerySnapshot> getUsersStream() {
    // Stream of snapshots from 'notes' collection ordered by timestamp in descending order
    final itemsStream = users.orderBy('email', descending: true).snapshots();
    return itemsStream;
  }


  // Method to update an existing note in Firestore
  Future<void> updateNote(String docID, String newNote, String newSubtext) {
    // Update the document with specified docID in 'notes' collection with new note content, subtext, and updated timestamp
    return notes.doc(docID).update({
      'note': newNote,
      'subtext': newSubtext, // Update subtext field
      'timestamp': Timestamp.now(),
    });
  }

  // Method to update an existing note in Firestore
  Future<void> updateItem(int itemId, String categoryName, String itemName, String itemDescription, double itemPrice, String ImageUrl) {
    // Update the document with specified docID in 'notes' collection with new note content, subtext, and updated timestamp
    return FirebaseFirestore.instance.collection('items').doc(itemId.toString()).update({

      'itemId': itemId,
      'categoryName': categoryName,
      'itemName': itemName,
      'itemDescription':itemDescription,
      'itemPrice':itemPrice,
      'imageUrl':ImageUrl,
    });
  }

  // Method to delete a note from Firestore
  Future<void> deleteNote(String docID) {
    // Delete the document with specified docID from 'notes' collection
    return notes.doc(docID).delete();
  }


  Future<void> deleteItem(int itemId, String imageUrl) async {
    try {
      // Delete the document from Firestore collection
      await items.doc(itemId.toString()).delete();

      // Extract the image name from the URL
      String imageName = extractFilenameFromUrl(imageUrl);
      print('Image Name: $imageName'); // Print the extracted image name

      // Reference the image in Firebase Storage
      Reference imageRef = _storage.ref().child('images/$imageName');

      // Delete the image from Firebase Storage
      await imageRef.delete();
    } catch (error) {
      throw Exception('Failed to delete item: $error');
    }
  }

  // Function to extract filename from URL
  String extractFilenameFromUrl(String imageUrl) {
    try {
      List<String> parts = imageUrl.split('/');
      String encodedFilename = parts.last;
      String decodedFilename = Uri.decodeComponent(encodedFilename);
      String filename = decodedFilename.split('/').last.split('?').first;
      return filename;
    } catch (e) {
      throw Exception('Failed to extract filename from URL: $e');
    }
  }


// Other methods...




  // Method to toggle the favorite status of a note
  Future<void> toggleFavorite(String docID, bool isFavorite) {
    // Update the document with specified docID in 'notes' collection with new favorite status
    return notes.doc(docID).update({
      'favorite': isFavorite,
    });
  }

  // Method to retrieve favorite notes from Firestore as a stream
  Stream<QuerySnapshot> getFavoriteNotesStream() {
    // Stream of snapshots from 'notes' collection where 'favorite' field is true
    final favoriteNotesStream = notes.where('favorite', isEqualTo: true).snapshots();
    return favoriteNotesStream;
  }
}
