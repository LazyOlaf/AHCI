import 'package:flutter/material.dart';
import 'registration_page.dart';
import 'main_screen.dart';
import 'widgets/mic_input_widget.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'widgets/biometric_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final flutterTts = FlutterTts();
  String name = '';
  String password = '';
  String? _errorMessage;

  void _logIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form fields

      bool isAuthenticated = false;
      final biometricHelper = BiometricHelper();

      try {
        isAuthenticated = await biometricHelper.authenticate();
      } catch (e) {
        print('Biometric authentication failed: $e');
      }

      final url = Uri.parse('http://localhost:3000/login');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'name': name,
        'password': isAuthenticated ? '' : password,
      });

      try {
        final response = await http.post(url, headers: headers, body: body);
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(userName: name)),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Login successful!')),
          );
        } else {
          setState(() {
            _errorMessage = data['error'] ?? 'Login failed. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Network error. Please try again later.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Log In',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 240, 240, 240),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Log in to your account to start enhancing your experience.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
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
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: const Icon(Icons.person_2_outlined, size: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                          ),
                          style: const TextStyle(fontSize: 14.0),
                          validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                          onSaved: (val) => name = val!,
                        ),
                        const SizedBox(height: 7),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, size: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                          ),
                          obscureText: true,
                          style: const TextStyle(fontSize: 14.0),
                          validator: (val) => val!.isEmpty ? 'Enter your password' : null,
                          onSaved: (val) => password = val!,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _logIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 67, 78, 234),
                              padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text('Log In', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Not registered? ',
                                style: TextStyle(fontSize: 14.0, color: Colors.black),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const RegistrationPage()),
                                  );
                                },
                                child: const Text(
                                  'Register.',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Color.fromARGB(255, 67, 78, 234),
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
                                _errorMessage = null;
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
          Expanded(
            flex: 1,
            child: MicInputWidget(flutterTts: flutterTts),
          ),
        ],
      ),
    );
  }
}
