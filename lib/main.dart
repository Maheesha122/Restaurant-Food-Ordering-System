// Import necessary packages for Firebase integration and Flutter UI components
import 'package:dominos/screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/cart.dart';
import 'screens/cartPage.dart';
import 'package:provider/provider.dart';
import 'screens/provider.dart'; // Import the UserProvider class

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:dominos/screens/home.dart';

import 'admin/adminHome.dart';
import 'admin/manageItems.dart';

// Asynchronous function to initialize Firebase and start the app
Future<void> main() async {
  // Ensure that Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Check if the app is running on the web platform
  if (kIsWeb) {
    // Initialize Firebase with specified options for web platform
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBvR6IiNjXtthoOt5QsCyXlFTGroa_ofvs",
          appId:"1:305353234287:web:135df9a91f3e200c08ba9a",
          messagingSenderId:  "G-L5147DLNZN",
          projectId: "foodie-pot"
      ),
    );
  } else {
    // Initialize Firebase for non-web platforms
    await Firebase.initializeApp();
  }

  // Start the Flutter app by running MyApp
  runApp(const MyApp());
}

// MyApp class, which represents the root of the application
class MyApp extends StatelessWidget {
  // Constructor for MyApp class
  const MyApp({Key? key});

  // Build method to define the UI structure of the application
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
    child: MaterialApp(

      title: 'Foodie Pot',
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splash: Image.asset(
          'assets/logo.png',
          height: 200,
          scale: 3.5, // Adjust the scale value to enlarge the image
        ),
        nextScreen: RegistrationPage(),
        splashTransition: SplashTransition.scaleTransition, duration: 3,
        // Adjust the duration for smoother transition
      ),
    )
    );
  }
}
