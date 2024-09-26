import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'About Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        color: Colors.yellow, // Set the background color to yellow
        child: Center(
          child: Container(
            width: 300, // Adjust width as needed
            height: 600, // Adjust height as needed
            decoration: BoxDecoration(
              color: Colors.white10, // Change background color as needed
              borderRadius: BorderRadius.circular(20), // Adjust border radius as needed
            ),
            child: Center(

              child: Column(
                children: [
                  SizedBox(height: 45.0,),
                  Text(
                    "A highly motivated and experienced restaurant team member with a proven track record of delivering excellent customer service and food quality.",
                    style: TextStyle(fontSize: 20.0,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.justify,

                  ),
                  SizedBox(height: 25.0,),

                  Text(
                    "Haven't you eaten ours yet....",
                    style: TextStyle(fontSize: 20.0,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 10.0,),
                  Text(
                    "     HOW SAD............",
                    style: TextStyle(fontSize: 30.0,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 10.0,),
                  Text(
                    "Would love to eat it......",
                    style: TextStyle(fontSize: 20.0,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),

            ),
          ),
        ),
      ),
    );
  }
}
