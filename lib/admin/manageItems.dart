import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dominos/admin/updateItem.dart';
import 'package:dominos/admin/viewItem.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/firestore.dart';
import 'deleteItem.dart';

class ManageItems extends StatefulWidget {
  const ManageItems({Key? key}) : super(key: key);

  @override
  State<ManageItems> createState() => _ManageItemsState();
}

class _ManageItemsState extends State<ManageItems> {
  final TextEditingController itemIdController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController =
  TextEditingController();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    return '';
  }

  void addItem() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemIdController,
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
              items: <String>[
                'Delux Burger',
                'Chicken Delight',
                'BoBo Joy',
                'Desserts'
              ].map<DropdownMenuItem<String>>((String value) {
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
              final String imageUrl =
              await uploadImage(selectedImageInBytes!);

              final QuerySnapshot<Map<String, dynamic>> existingItem =
              await FirebaseFirestore.instance
                  .collection('items')
                  .where('itemId', isEqualTo: int.parse(enteredItemId))
                  .get();

              if (existingItem.docs.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(
                        'An item with the same Item ID already exists.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }

              // Add item data to Firestore using FireStoreService
              await _fireStoreService.addItem(
                int.parse(enteredItemId),
                _selectedMeal,
                itemNameController.text,
                itemDescriptionController.text,
                double.parse(itemPriceController.text),
                imageUrl,
              );

              // Show success toast
              Fluttertoast.showToast(
                msg: "Item added successfully",
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
            child: Text("Add Item"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Manage Items',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: ListView(
        children: [
          SizedBox(height: 30.0),
          _buildManageItemCard(
            title: 'View Items',
            icon: Icons.list,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewItem()),
              );
            },
          ),
          _buildManageItemCard(
            title: 'Add Item',
            icon: Icons.add,
            onTap: addItem,
          ),
          _buildManageItemCard(
            title: 'Update Item',
            icon: Icons.update,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdateItem()),
              );
            },
          ),
          _buildManageItemCard(
            title: 'Delete Item',
            icon: Icons.delete,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeleteItem()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManageItemCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.yellow[500],
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        trailing: Icon(
          icon,
          color: Colors.blue[900],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
