import 'package:flutter/material.dart';

class ManageBanners extends StatefulWidget {
  const ManageBanners({super.key});

  @override
  State<ManageBanners> createState() => _ManageBannersState();
}

class _ManageBannersState extends State<ManageBanners> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Items'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("hi! manage banners here"),
          ],
        ),
      ),
    );
  }
}
