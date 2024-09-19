import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool showNextPage = false;

  final _formKey = GlobalKey<FormState>();

  // Controllers for first page inputs
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Controllers for second page inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();

  void moveToNextPage() {
    if (_formKey.currentState!.validate()) {
      // Clear second page fields
      _nameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      _instituteController.clear();

      setState(() {
        showNextPage = true;
      });
    }
  }

  void createAccount() {
    if (_formKey.currentState!.validate()) {
      // Handle account creation here
    }
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _instituteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00A1E4), // Light blue background color
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(
                    0xFFB3E5FC), // Pastel light blue card background
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to the left
                  children: [
                    const SizedBox(height: 20),

                    // Sign Up Title aligned to the left
                    const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Darker text color
                      ),
                      textAlign: TextAlign.left, // Align text to the left
                    ),

                    const SizedBox(height: 8),

                    // "Already have an account?" Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Navigate back to login
                          },
                          child: const Text(
                            "Sign IN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.blue, // Accent color for Sign IN text
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // First Page of Sign Up (Username, Password, Confirm Password)
                    if (!showNextPage) ...[
                      TextFormField(
                        controller: _usernameController, // Bind controller
                        decoration: InputDecoration(
                          hintText: "Username",
                          labelText: "Username",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Username cannot be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController, // Bind controller
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Create Password",
                          labelText: "Password",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password cannot be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller:
                            _confirmPasswordController, // Bind controller
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          labelText: "Confirm Password",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: moveToNextPage,
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ]

                    // Second Page of Sign Up (Name, Phone, Email, Institute)
                    else ...[
                      TextFormField(
                        controller: _nameController, // Bind controller
                        decoration: InputDecoration(
                          hintText: "Name",
                          labelText: "Name",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneNumberController, // Bind controller
                        decoration: InputDecoration(
                          hintText: "Phone No.",
                          labelText: "Phone No.",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController, // Bind controller
                        decoration: InputDecoration(
                          hintText: "Email",
                          labelText: "Email",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _instituteController, //Bind controller
                        decoration: InputDecoration(
                          hintText: "Institute Name",
                          labelText: "Institute Name",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: createAccount,
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
