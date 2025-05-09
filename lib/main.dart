import 'package:flutter/material.dart';
import 'package:flutter_application_1/main_screen.dart';
import 'registration_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the "debug" banner
      title: 'Accessible Navigation',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/registration',
      onGenerateRoute: (settings) {
        if (settings.name == '/main_screen') {
          final args = settings.arguments as String; // Retrieve the username
          return MaterialPageRoute(
            builder: (context) => MainScreen(userName: args),
          );
        } else if (settings.name == '/registration') {
          return MaterialPageRoute(
            builder: (context) => const RegistrationPage(),
          );
        }
        return null; // Return null if the route is not defined
      },
    );
  }
}
