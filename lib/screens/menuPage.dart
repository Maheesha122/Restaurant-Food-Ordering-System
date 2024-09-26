import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cartPage.dart';
import 'descriptionPage.dart';

class MenuScreen extends StatefulWidget {
  final int initialTabIndex;

  const MenuScreen({Key? key, required this.initialTabIndex}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<Map<String, dynamic>>> _itemListFuture;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _itemListFuture = _fetchItems();
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('items').get();

      final itemList = querySnapshot.docs.map((doc) {
        return {
          'itemName': doc['itemName'] ?? 'No Name',
          'itemDescription': doc['itemDescription'] ?? 'No Description',
          'itemPrice': (doc['itemPrice'] ?? 0.0).toDouble(), // Convert to double
          'imageUrl': doc['imageUrl'] ?? '',
          'categoryName': doc['categoryName'] ?? 'No Category',
        };
      }).toList();

      print('Fetched items: $itemList');

      return itemList;
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Number of tabs
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.red,
          title: Text(
            "Hi Food Lovers",
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(child: Text('All')),
              Tab(child: Text('Delux Burger')),
              Tab(child: Text('Chicken Delight')),
              Tab(child: Text('BoBo Joy')),
              Tab(child: Text('Desserts')),
            ],
            labelColor: Colors.yellowAccent,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 20.0,),
            _buildSearchBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent('All'),
                  _buildTabContent('Delux Burger'),
                  _buildTabContent('Chicken Delight'),
                  _buildTabContent('BoBo Joy'),
                  _buildTabContent('Desserts'),
                ],
              ),
            ),
          ],
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 250.0, // Adjust the width as needed
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              hintText: 'Search for food items...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTabContent(String tabLabel) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _itemListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final itemList = snapshot.data!;
          List<Map<String, dynamic>> filteredItems = [];

          if (tabLabel == 'All') {
            filteredItems = itemList;
          } else {
            filteredItems = itemList
                .where((item) => item['categoryName'] == tabLabel)
                .toList();
          }

// Filter items based on search text
          if (_searchText.isNotEmpty) {
            filteredItems = filteredItems
                .where((item) =>
            item['itemName'] != null && item['itemName'].toLowerCase().contains(_searchText.toLowerCase()))
                .toList();
          }



          return _buildHorizontalCards(filteredItems);
        }
      },
    );
  }

  Widget _buildHorizontalCards(List<Map<String, dynamic>> itemList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(26.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          (itemList.length / 2).ceil(),
              (rowIndex) {
            final startIndex = rowIndex * 2;
            final endIndex = startIndex + 2;
            final rowItems = itemList
                .sublist(startIndex, endIndex.clamp(0, itemList.length))
                .map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildCard(
                    context,
                    item['itemName'],
                    item['itemDescription'],
                    item['itemPrice'],
                    item['imageUrl'],
                  ),
                ),
              );
            }).toList();

            if (rowItems.length == 1) {
              return Row(
                children: [
                  rowItems[0],
                  SizedBox(width: 160.0 + 4.0),
                ],
              );
            } else {
              return Row(children: rowItems);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String itemName, String itemDescription, double itemPrice, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DescriptionPage(
              itemName: itemName,
              itemDescription: itemDescription,
              itemPrice: itemPrice,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 160.0,
        child: Card(
          color: Color(0xfff1f0e7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Text(
                  '$itemName',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 95.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rs. $itemPrice',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Icon(
                            Icons.add_circle,
                            color: Colors.orange,
                            size: 22.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
