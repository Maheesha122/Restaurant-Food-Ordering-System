import 'package:flutter/material.dart';

class Item {
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  Item ({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
}
