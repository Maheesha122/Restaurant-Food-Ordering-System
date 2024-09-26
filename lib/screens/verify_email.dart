import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dominos/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/firestore.dart';

class VerifyEmail extends StatefulWidget {
  final String email;
  final String username;
  final String password;
  final String phoneNumber;
  final String address;

  const VerifyEmail({
    Key? key,
    required this.email,
    required this.username,
    required this.password,
    required this.phoneNumber,
    required this.address,
  }) : super(key: key);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  String? sentOtp; // Store the OTP sent via email in the state
  final TextEditingController _otpController = TextEditingController();
  String enteredOtp = ''; // Store the entered OTP

  final FireStoreService _fireStoreService = FireStoreService();

  String generateOTP() {
    Random random = Random();
    int otp = random.nextInt(90000) + 10000; // Generates a random number between 10000 and 99999
    return otp.toString();
  }

  Future<void> sendTransactionalEmail(String recipientEmail, String subject, String body) async {
    String apiKey = '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';
    String apiUrl = 'https://api.sendinblue.com/v3/smtp/email';

    Map<String, dynamic> requestBody = {
      'sender': {'email': 'maheeshahere@gmail.com'},
      'to': [{'email': recipientEmail}],
      'subject': subject,
      'htmlContent': body,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'api-key': apiKey,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        print('Email sent successfully');
      } else {
        print('Failed to send email. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  Future<void> sendOtpButtonPressed() async {
    String recipientEmail = widget.email;
    String otp = generateOTP(); // Generate OTP
    String emailBody = 'Your OTP is: $otp'; // Use generated OTP
    await sendTransactionalEmail(recipientEmail, 'Email Verification', emailBody);
    setState(() {
      sentOtp = otp; // Store the OTP sent via email
    });
    print('Email sent successfully to: $recipientEmail');
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent successfully'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Email Verification',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20.0,),
            ElevatedButton(
              onPressed: sendOtpButtonPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
              ),
              child: Text(
                'Send the OTP',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 46),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  enteredOtp = value.trim(); // Update enteredOtp in the state
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (enteredOtp == sentOtp) {
                  // If entered OTP matches the sent OTP
                  final hashedPassword = sha256.convert(utf8.encode(widget.password)).toString();
                  try {
                    // Check if the email already exists in the database
                    final existingUser = await FirebaseFirestore.instance.collection('users').doc(widget.email).get();
                    if (existingUser.exists) {
                      // Email is already registered, show error message to the user
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Email is already registered. Please use a different email.'),
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
                    // Email is unique, proceed with user registration
                    await FirebaseFirestore.instance.collection('users').doc(widget.email).set({
                      'email': widget.email,
                      'username': widget.username,
                      'password': hashedPassword,// Store hashed password in Firestore
                      'phoneNumber':widget.phoneNumber,
                      'address':widget.address,
                    });
                    // Registration successful, navigate to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } catch (e) {
                    // Handle registration errors
                    print('Error registering user: $e');
                  }
                } else {
                  // If entered OTP is invalid
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid OTP'),
                        content: Text('The OTP is invalid.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
              ),
              child: Text(
                'Verify OTP',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
