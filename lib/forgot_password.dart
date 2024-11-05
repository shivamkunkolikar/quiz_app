import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';





class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _usernameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword(username, eemail) async {
    // String email = _emailPhoneController.text.trim();
    if(_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords Do Not match'))
      );
    }
    else {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc = await firestore.collection('users').doc(username).get();

      if (userDoc.exists) {
        String storedPassword = userDoc['email'];
        if (storedPassword == eemail) {

            Map<String, dynamic> userMap = {
              'username': userDoc['username'],
              'password': _newPasswordController.text,
              'email': userDoc['email'],
              'name': userDoc['name'],
              'phno': userDoc['phno'],
              'institute': userDoc['institute'],
              'createdTests': userDoc['createdTests'],
              'answeredTests': userDoc['answeredTests'],
          };

          CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
          await usersCollection.doc(username).set(userMap);
          email = userDoc['email'];
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('username', username);
          prefs.setString('email', email);
          print('Done');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password Reset Successful'))
          );
          // return true;
        } else {
          // return false;
          print('false');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email not matching user credential entered during sign up'))
          );
        }
      } else {
        print('false');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password Reset Unsuccsesful'))
          );
        // return false;
      }
    } catch (e) {
      print('Error fetching user credentials: $e');
      // return false;
    }
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
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailPhoneController,
                        decoration: const InputDecoration(
                          labelText: "Email ",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Create New Password",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Confirm Password",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Material(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () async{ await resetPassword(_usernameController.text, _emailPhoneController.text);},
                          child: const SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Reset Password",
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