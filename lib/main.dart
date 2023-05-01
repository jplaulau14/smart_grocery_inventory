import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/signup.dart';
import 'screens/login.dart';
import 'screens/personal_inventory_form.dart';
import 'home_page.dart'; // Make sure to import the HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute:
          '/login_screen', // Set the initial route to the login screen
      routes: {
        '/login_screen': (context) => const LoginScreen(),
        '/signup_screen': (context) => const SignupScreen(),
        '/personal_inventory_form': (context) =>
            const PersonalInventoryFormScreen(), // Add this line
        '/main_screen': (context) =>
            const HomePage(), // Add this line for the new route
        // Add other routes here
      },
    );
  }
}
