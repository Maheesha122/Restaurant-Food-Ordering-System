import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/firestore.dart';

class UpdateItem extends StatefulWidget {
  const UpdateItem({Key? key}) : super(key: key);

  @override
  State<UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<UpdateItem> {
  late Future<List<Map<String, dynamic>>> _itemListFuture;
  final TextEditingController itemIdController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();

  late Stream<QuerySnapshot> _itemsStream;

  String _imageFile = ''; // Variable to hold the selected image file
  Uint8List? selectedImageInBytes;

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://foodie-pot.appspot.com',
  );

  final FireStoreService _fireStoreService = FireStoreService();

  String _selectedMeal = 'Delux Burger'; // Default selection

  @override
  void initState() {
    super.initState();
    // Initialize Firestore service and items stream
    _itemsStream = FirebaseFirestore.instance.collection('items').snapshots();
    // Initialize the future to fetch item data
    _itemListFuture = _fetchItems();
  }

  Future<void> pickImage() async {
    try {
      // Pick image using file_picker package
      FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      // If user picks an image, save selected image to variable
      if (fileResult != null) {
        setState(() {
          _imageFile = fileResult.files.first.name!;
          selectedImageInBytes = fileResult.files.first.bytes;
        });
      }
    } catch (e) {
      // If an error occurred, show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<String> uploadImage(Uint8List selectedImageInBytes) async {
    try {
      // This is reference where image uploaded in firebase storage bucket
      Reference ref = _storage.ref().child('images/$_imageFile');

      // Metadata to save image extension
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      // UploadTask to finally upload image
      UploadTask uploadTask = ref.putData(selectedImageInBytes, metadata);

      // After successfully upload show SnackBar
      await uploadTask.whenComplete(() => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Image Uploaded"))));
      return await ref.getDownloadURL();
    } catch (e) {
      // If an error occurred while uploading, show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    return '';
  }

  void updateSelectedItem() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemIdController,
              enabled: false,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Item ID',
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedMeal,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMeal = newValue!;
                });
              },
              items: <String>['Delux Burger', 'Chicken Delight', 'Bobo Joy','Ice Cream']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: itemNameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
              ),
            ),
            TextField(
              controller: itemDescriptionController,
              decoration: InputDecoration(
                labelText: 'Item Description',
              ),
            ),
            TextField(
              controller: itemPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Item Price',
              ),
            ),
            ListTile(
              leading: Icon(Icons.image_rounded),
              title: Text('Upload Image'),
              onTap: () => pickImage(),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final String enteredItemId = itemIdController.text.trim();
              final String imageUrl = await uploadImage(selectedImageInBytes!);

              final QuerySnapshot<Map<String, dynamic>> existingItem =
              await FirebaseFirestore.instance
                  .collection('items')
                  .where('itemId', isEqualTo: int.parse(enteredItemId))
                  .get();

              // Add item data to Firestore using FireStoreService
              await _fireStoreService.updateItem(
                int.parse(enteredItemId),
                _selectedMeal,
                itemNameController.text,
                itemDescriptionController.text,
                double.parse(itemPriceController.text),
                imageUrl,
              );

              // Show success toast
              Fluttertoast.showToast(
                msg: "Item updated successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );

              // Clear text controllers
              itemIdController.clear();
              itemNameController.clear();
              itemDescriptionController.clear();
              itemPriceController.clear();

              // Close the dialog
              Navigator.pop(context);
            },
            child: Text("Update Item"),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    // Fetch item data from Firestore
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('items').get();

    // Extract item IDs and names
    return querySnapshot.docs.map((doc) {
      return {
        'itemId': doc['itemId'],
        'itemName': doc['itemName'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Update Item',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _itemListFuture,
          builder: (context, snapshot) {
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
                  final item = itemList[index];
                  return Card(
                    color: Color(0xffbeecfd),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ' ${item['itemId']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            ' ${item['itemName']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onTap: () async {

                        // Show the update dialog
                        updateSelectedItem();
                        // Fetch the item details from Firestore
                        QuerySnapshot<Map<String, dynamic>> itemSnapshot = await FirebaseFirestore.instance
                            .collection('items')
                            .where('itemId', isEqualTo: item['itemId'])
                            .limit(1)
                            .get();

                        if (itemSnapshot.docs.isNotEmpty) {
                          // Extract item data from the snapshot
                          Map<String, dynamic> itemData = itemSnapshot.docs.first.data();

                          // Set the retrieved data to the form fields
                          setState(() {
                            itemIdController.text = itemData['itemId'].toString();
                            _selectedMeal = itemData['mealCategory'];
                            itemNameController.text = itemData['itemName'];
                            itemDescriptionController.text = itemData['itemDescription'];
                            itemPriceController.text = itemData['itemPrice'].toString();
                            // You may need to handle imageUrl retrieval based on your implementation
                          });

                        } else {
                          // Show an error message if item details are not found
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Item details not found')),
                          );
                        }
                      },


                      trailing: Icon(Icons.update,
                      color: Colors.blue[900]),
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
