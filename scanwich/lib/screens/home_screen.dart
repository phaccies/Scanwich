import 'package:flutter/material.dart';
import 'profile_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7FC8F8), // Light Sky Blue
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stacked "Scanwich" text
          SizedBox(
            height: 160, // enough room for all layers
            child: Stack(
              alignment: Alignment.center,
              children: const [
                // White (back)
                Positioned(
                  top: 0,
                  child: Text(
                    'Scanwich',
                    style: TextStyle(
                      fontFamily: 'Caprasimo',
                      fontSize: 48,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFF9F9F9), // White
                    ),
                  ),
                ),
                // Yellow (middle)
                Positioned(
                  top: 25,
                  child: Text(
                    'Scanwich',
                    style: TextStyle(
                      fontFamily: 'Caprasimo',
                      fontSize: 48,
                      fontWeight: FontWeight.w400,
                      color: Color( 0xFFEE4266), // Red
                    ),
                  ),
                ),
                // Red (front)
                Positioned(
                  top: 50,
                  child: Text(
                    'Scanwich',
                    style: TextStyle(
                      fontFamily: 'Caprasimo',
                      fontSize: 48,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFFE45E), // Yellow
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // "Get Started!" Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Get Started!'),
          ),
        ],
      ),
    );
  }
}