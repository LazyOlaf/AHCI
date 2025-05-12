import 'package:flutter/material.dart';
import 'registration_page.dart'; // Import the Registration Page
import 'main_screen.dart'; // Your main object detection/navigation screen
import 'widgets/mic_input_widget.dart'; // Import the MicInputWidget
import 'package:flutter_tts/flutter_tts.dart'; // Import FlutterTts package

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final flutterTts = FlutterTts(); // Initialize FlutterTts instance
  String name = '';
  String password = '';

  void _logIn() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(userName: name)),
      );
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
                'Log In',
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
                  'Log in to your account to start enhancing your experience.',
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
          // Upper 50%: Log In Form
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
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
                      style: const TextStyle(fontSize: 14.0), // Set custom font size
                      validator: (val) => val!.isEmpty ? 'Enter your password' : null,
                      onSaved: (val) => password = val!,
                    ),
                    const SizedBox(height: 20),

                    // Log In Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _logIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 67, 78, 234), // Consistent blue color
                          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Not Registered? Register
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Not registered? ', // Plain text
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black, // Regular black color for plain text
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to Registration Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegistrationPage()),
                              );
                            },
                            child: const Text(
                              'Register.', // Link text
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color.fromARGB(255, 67, 78, 234), // Consistent blue color for link
                                fontWeight: FontWeight.bold,
                                //decoration: TextDecoration.underline, // Underline for link effect
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
          ),

          // Lower 50%: Mic Input Widget
          Expanded(
            flex: 1,
            child: MicInputWidget(flutterTts: flutterTts),
          ),
        ],
      ),
    );
  }
}