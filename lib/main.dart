import 'package:flutter/material.dart';
import 'package:flutter_application_1/profile_page.dart';
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
        '/profile': (context) => const ProfilePage(userName: 'User'),
      },
    );
  }
}
