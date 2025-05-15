import 'package:flutter/material.dart';
import 'widgets/mic_input_widget.dart'; // Import the MicInputWidget
import 'package:flutter_tts/flutter_tts.dart'; // Import FlutterTts package
import 'login_page.dart';
import 'widgets/biometric_helper.dart'; // Import the BiometricHelper class
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final flutterTts = FlutterTts(); // Initialize FlutterTts instance
  String name = '';
  String email = '';
  String password = '';
  bool _agreeToTerms = false;
  String? _errorMessage; // To store error messages

  void _register() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      bool isAuthenticated = false;

      // Attempt biometric authentication
      final biometricHelper = BiometricHelper();
      try {
        isAuthenticated = await biometricHelper.authenticate();
      } catch (e) {
        print('Biometric authentication skipped or failed: $e');
      }

      // Save form data and proceed with registration
      _formKey.currentState!.save();

      // Send data to the backend
      final url = Uri.parse('http://localhost:3000/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'password': password,
          'biometricUsed': isAuthenticated, // Optional: Track biometric usage
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
      } else {
        setState(() {
          _errorMessage = jsonDecode(response.body)['error'];
        });
      }
    } else if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'You must agree to the terms and conditions.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // White background
        toolbarHeight: 100, // Increase height to fit both title and subtitle
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 20.0), // Adjust padding for proper alignment
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center, // Center-align the title
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12), // Padding inside the rounded container
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 240, 240), // Light gray background
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: const Text(
                  'Create your account to start enhancing your experience.',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center, // Center-align the subtitle
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Top 50%: Registration Form
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name Field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(
                              Icons.person_2_outlined, // User icon
                              size: 18.0, // Adjust the icon size
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30), // Rounded corners
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15), // Adjust padding for shorter height
                          ),
                          style: const TextStyle(fontSize: 14.0), // Set custom font size
                          validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                          onSaved: (val) => name = val!,
                        ),
                        const SizedBox(height: 7),

                        // Email Field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined, size: 18.0,), // Email icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30), // Rounded corners
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15), // Adjust padding for shorter height
                          ),
                          validator: (val) => val!.contains('@') ? null : 'Enter valid email',
                          onSaved: (val) => email = val!,
                        ),
                        const SizedBox(height: 7),

                        // Password Field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, size: 18.0,), // Lock icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30), // Rounded corners
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15), // Adjust padding for shorter height
                          ),
                          obscureText: true,
                          validator: (val) => val!.length < 6 ? 'Password too short' : null,
                          onSaved: (val) => password = val!,
                        ),
                        const SizedBox(height: 5),

                        // Terms and Conditions Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value!;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'I agree with terms and conditions',
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Register Button
                        Center(
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 67, 78, 234), // Consistent blue color
                              padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Already Registered? Log In
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already registered? ', // Plain text
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black, // Regular black color for plain text
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to login page (replace with actual login page)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginPage()),
                                  );
                                },
                                child: const Text(
                                  'Log In.', // Link text
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Color.fromARGB(255, 67, 78, 234), // Consistent blue color for link
                                    fontWeight: FontWeight.bold,
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

                // Error Message Overlay
                if (_errorMessage != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _errorMessage = null; // Clear the error message
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom 50%: Mic Input Widget
          Expanded(
            flex: 1,
            child: MicInputWidget(flutterTts: flutterTts),
          ),
        ],
      ),
    );
  }
}
