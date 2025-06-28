import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _allergiesController = TextEditingController();
  static const String _allergiesKey = 'user_allergies';

  @override
  void initState() {
    super.initState();
    _loadAllergies();
  }

  Future<void> _loadAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allergiesController.text = prefs.getString(_allergiesKey) ?? '';
    });
  }

  Future<void> _saveAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_allergiesKey, _allergiesController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allergies saved!')),
      );
    }
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Allergy Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tell us what you are allergic to.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter them below, separated by commas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Allergies',
                  hintText: 'e.g., peanuts, milk, gluten',
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAllergies,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}