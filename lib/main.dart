import 'package:flutter/material.dart';
import 'get_started_page.dart';
import 'registration_page.dart';
import 'main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VisionAid',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStartedPage(),
        '/registration': (context) => const RegistrationPage(),
        '/main_screen': (context) => MainScreen(userName: 'User'), // Example
      },
    );
  }
}
