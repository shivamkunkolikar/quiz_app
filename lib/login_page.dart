
import 'package:flutter/material.dart';
import 'package:quiz_app/home_page.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:quiz_app/main.dart';
// import 'package:project/utils/routes.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app/signup_page.dart'; // Import the sign-up page


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = "";
  String password = "";
  bool changeButton = false;
  bool isLoggedIn = false;

  Future<bool> is_correct(String username, String password) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc = await firestore.collection('users').doc(username).get();

      if (userDoc.exists) {
        String storedPassword = userDoc['password'];
        if (storedPassword == password) {
          email = userDoc['email'];
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('username', username);
          prefs.setString('email', email);
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('Error fetching user credentials: $e');
      return false;
    }
  }


  moveToHome(BuildContext context) async {
    isLoggedIn = await is_correct(username, password);
    
    print(username);
    if(isLoggedIn) {
      await updateHomeInfo();
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect Username or Password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity, 
          height: MediaQuery.of(context).size.height, 
          color: const Color(0xFF00A1E4), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                color: const Color(0xFFB3E5FC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the sign-up page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupPage(), // Navigate to SignUpPage
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Enter username",
                          labelText: "Username",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: (value) {
                          // Handle changes
                          username = value;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Enter password",
                          labelText: "Password",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: (value) {
                          password = value;
                        },
                      ),

                      const SizedBox(height: 24),

                      Material(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            moveToHome(context);
                          },
                          child: const SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          // Navigate to forgot password
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}