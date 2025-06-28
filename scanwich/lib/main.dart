import 'package:flutter/material.dart';
import 'package:scanwich/screens/home_screen.dart';
import 'package:scanwich/screens/profile_screen.dart';
import 'package:scanwich/screens/scan_screen.dart';

void main() {
  runApp(const ScanwichApp());
}

class ScanwichApp extends StatelessWidget {
  const ScanwichApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanwich',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(title: 'Scanwich'),
        '/scan': (context) => const ScanScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
