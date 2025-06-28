import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _searchController = TextEditingController();
  static const String _allergiesKey = 'user_allergies';

  final List<String> _allAllergens = [
    'Celery', 'Gluten', 'Crustaceans', 'Eggs', 'Fish', 'Lupin', 'Milk',
    'Molluscs', 'Mustard', 'Peanuts', 'Sesame', 'Soybeans', 'Sulphites', 'Tree Nuts'
  ];

  List<String> _filteredAllergens = [];
  final Set<String> _selectedAllergens = {};

  @override
  void initState() {
    super.initState();
    _filteredAllergens = List.from(_allAllergens);
    _loadAllergies();
    _searchController.addListener(_filterAllergens);
  }

  void _filterAllergens() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAllergens = _allAllergens.where((allergen) {
        return allergen.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAllergies = prefs.getStringList(_allergiesKey) ?? [];
    setState(() {
      _selectedAllergens.clear();
      _selectedAllergens.addAll(savedAllergies);
    });
  }

  Future<void> _saveAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_allergiesKey, _selectedAllergens.toList());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allergies saved!')),
      );
    }
  }

  void _onAllergenSelected(bool selected, String allergen) {
    setState(() {
      if (selected) {
        _selectedAllergens.add(allergen);
      } else {
        _selectedAllergens.remove(allergen);
      }
    });
  }

  void _showAddCustomAllergenDialog() {
    final TextEditingController customController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Allergen'),
        content: TextField(
          controller: customController,
          decoration: const InputDecoration(hintText: 'Enter allergen name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final customName = customController.text.trim();
              if (customName.isNotEmpty &&
                  !_allAllergens.any((a) => a.toLowerCase() == customName.toLowerCase())) {
                setState(() {
                  _allAllergens.add(customName);
                  _filteredAllergens = List.from(_allAllergens);
                  _selectedAllergens.add(customName);
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Allergy Profile'),
        backgroundColor: const Color(FFE45E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select your allergies from the list below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search Allergens',
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: _showAddCustomAllergenDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Custom Allergen',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_selectedAllergens.isNotEmpty) ...[
              const Text(
                'Your Selections:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _selectedAllergens.map((allergen) {
                  return Chip(
                    label: Text(allergen),
                    onDeleted: () => _onAllergenSelected(false, allergen),
                    deleteIconColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              const Divider(height: 30),
            ],

            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _filteredAllergens
                      .where((a) => !_selectedAllergens.contains(a))
                      .map((a) => FilterChip(
                            label: Text(a),
                            selected: _selectedAllergens.contains(a),
                            onSelected: (val) => _onAllergenSelected(val, a),
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            checkmarkColor: Theme.of(context).colorScheme.primary,
                          ))
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAllergies,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}