import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controller for the search text field.
  final _searchController = TextEditingController();
  // Key for storing and retrieving allergies from local storage.
  static const String _allergiesKey = 'user_allergies';

  // A predefined, static list of all possible common allergens.
  final List<String> _allAllergens = [
    'Celery', 'Gluten', 'Crustaceans', 'Eggs', 'Fish', 'Lupin', 'Milk',
    'Molluscs', 'Mustard', 'Peanuts', 'Sesame', 'Soybeans', 'Sulphites', 'Tree Nuts'
  ];

  // The list of allergens to display to the user, after filtering by search.
  List<String> _filteredAllergens = [];
  // A set to hold the allergens the user has currently selected.
  final Set<String> _selectedAllergens = {};

  @override
  void initState() {
    super.initState();
    // Initially, the filtered list is the complete list of allergens.
    _filteredAllergens = _allAllergens;
    // Load any previously saved allergies from local storage.
    _loadAllergies();
    // Add a listener to the search controller to filter the list in real-time.
    _searchController.addListener(_filterAllergens);
  }

  // Filters the list of allergens based on the user's search query.
  void _filterAllergens() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // We filter the master list of all allergens.
      _filteredAllergens = _allAllergens.where((allergen) {
        // An allergen is included if its name contains the search query.
        return allergen.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Asynchronously loads the user's saved allergies from SharedPreferences.
  Future<void> _loadAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the list of strings, or an empty list if none are saved.
    final savedAllergies = prefs.getStringList(_allergiesKey) ?? [];
    setState(() {
      // Clear the current selection and add all the loaded allergies.
      _selectedAllergens.clear();
      _selectedAllergens.addAll(savedAllergies);
    });
  }

  // Asynchronously saves the user's current selection to SharedPreferences.
  Future<void> _saveAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the set of selected allergens to a list and save it.
    await prefs.setStringList(_allergiesKey, _selectedAllergens.toList());

    // Show a confirmation message to the user if the widget is still on screen.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allergies saved!')),
      );
    }
  }

  // Handles the tap event on a FilterChip.
  void _onAllergenSelected(bool selected, String allergen) {
    setState(() {
      // If the chip is selected, add the allergen to the set.
      if (selected) {
        _selectedAllergens.add(allergen);
      } else {
        // Otherwise, remove it.
        _selectedAllergens.remove(allergen);
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Allergy Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informational text for the user.
            const Text(
              'Select your allergies from the list below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            // Search input field.
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search Allergens',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            // This section displays the list of currently selected allergens.
            // It only appears if at least one allergen is selected.
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
                  // Use a regular Chip with a delete icon for selected items.
                  return Chip(
                    label: Text(allergen),
                    onDeleted: () {
                      // Tapping the delete icon deselects the allergen.
                      _onAllergenSelected(false, allergen);
                    },
                    deleteIconColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              const Divider(height: 30),
            ],
            // A scrollable, expanding list of all available filter chips.
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  // We map over the filtered list to create a chip for each allergen
                  // that has NOT already been selected.
                  children: _filteredAllergens
                      .where((allergen) => !_selectedAllergens.contains(allergen))
                      .map((allergen) {
                    return FilterChip(
                      label: Text(allergen),
                      // The chip is selected if it's in our set of selected allergens.
                      selected: _selectedAllergens.contains(allergen),
                      // The callback function to handle selection changes.
                      onSelected: (selected) {
                        _onAllergenSelected(selected, allergen);
                      },
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // The button to save the user's choices to local storage.
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