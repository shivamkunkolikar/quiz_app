import 'package:flutter/material.dart';
import 'package:quiz_app/home_page.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:quiz_app/main.dart';
// import 'package:project/utils/routes.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = "";
  bool changeButton = false;
  bool login_true = false;
  // final _formKey = GlobalKey<FormState>();

  Future<bool> is_correct(username, password) async{
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc = await firestore.collection('users').doc(username).get();

      if (userDoc.exists) {
        String storedPassword = userDoc['password'];
        if (storedPassword == password) {
          email = userDoc['email'];
          createdTests = userDoc['createdTests'];
          answeredTests = userDoc['answeredTests'];
          for(int i=0 ; i<createdTests.length ; i++) {
            Map? tmp = await getDocField(createdTests[i]);
            createdTestsObject.add(tmp);
          }

          for(int i=0 ; i<answeredTests.length ; i++) {
            Map? tmp = await getDocField(answeredTests[i]);
            answeredTestsObject.add(tmp);
          }
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
    login_true = await is_correct(username, password);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('email', email);
    print(username);
    if(login_true) {
      setState(() { changeButton = true; });
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));

      setState(() { changeButton = false; });
    }
    else {
      setState(() { changeButton = true; });
      await Future.delayed(const Duration(seconds: 1));
      setState(() { changeButton = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Material(
          color: Colors.white,
          child: Column(
            children: [

              const SizedBox(height: 20), // Add space between the image and text
              
              Text(
                "Welcome $name",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20), // Add space between text and form fields
              
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 32.0),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Enter username",
                        labelText: "Username",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Username cannot be empty";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        name = value;
                        username = value;
                        setState(() {});
                      },
                    ),

                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Enter password",
                        labelText: "Password",
                      ),
                      onChanged: (value) {
                        password = value;
                      },
              
                    ),

                    const SizedBox(height: 20),

                    Material(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(changeButton ? 50 : 8),
                      child: InkWell(
                        splashColor: const Color.fromARGB(255, 126, 90, 189),
                        onTap: () => moveToHome(context),
                        child: AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          width: changeButton ? 90 : 140,
                          height: 50,
                          alignment: Alignment.center,
                          child: changeButton
                              ? login_true ? 
                                  const Icon(Icons.done, color: Colors.white,)
                                : const Icon(Icons.close, color: Colors.white,)
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}