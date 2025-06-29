import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String productName = '';
  String ingredients = '';
  String error = '';
  bool isLoading = false;
  List<String> matchedAllergens = [];

  Future<List<String>> _loadUserAllergens() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('user_allergies') ?? [];
}


// added here 4 scanning
Future<void> fetchProductWithBarcode(String barcode) async {
  setState(() {
    isLoading = true;
    error = '';
    productName = '';
    ingredients = '';
    matchedAllergens = [];
  });

  final url = Uri.parse(
    'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final product = data['product'];
      final name = product['product_name'] ?? 'Unknown Product';
      final ingText = product['ingredients_text']?.toLowerCase() ?? '';

      final userAllergens = await _loadUserAllergens();
      final found = userAllergens
          .where((allergen) => ingText.contains(allergen.toLowerCase()))
          .toList();

      setState(() {
        productName = name;
        ingredients = ingText;
        matchedAllergens = found;
      });
    } else {
      setState(() {
        error = 'Failed to load product data.';
      });
    }
  } catch (e) {
    setState(() {
      error = 'An error occurred: $e';
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
//end 

Future<void> fetchProduct() async {
  setState(() {
    isLoading = true;
    error = '';
    productName = '';
    ingredients = '';
    matchedAllergens = []; // ← new variable
  });

  const String testBarcode = '51500241776';
  final url = Uri.parse(
    'https://world.openfoodfacts.org/api/v0/product/$testBarcode.json'
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final product = data['product'];

      final name = product['product_name'] ?? 'Unknown Product';
      final ingText = product['ingredients_text']?.toLowerCase() ?? '';

      // Load user allergens
      final userAllergens = await _loadUserAllergens();

      // Match against ingredients
      final found = userAllergens.where((allergen) =>
        ingText.contains(allergen.toLowerCase())).toList();

      setState(() {
        productName = name;
        ingredients = ingText;
        matchedAllergens = found;
      });

    } else {
      setState(() {
        error = 'Failed to load product data.';
      });
    }
  } catch (e) {
    setState(() {
      error = 'An error occurred: $e';
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 150,
                  color: theme.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ready to Scan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Click the button below to test with a sample barcode.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final barcode = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerScreen(),
                      ),
                    );

                    if (barcode != null) {
                      fetchProductWithBarcode(barcode);
                    }
                  },
                  child: const Text('Scan Barcode'),
                ),

                const SizedBox(height: 20),
                if (isLoading) const CircularProgressIndicator(),
                if (error.isNotEmpty)
                  Text(error,
                      style: const TextStyle(color: Colors.red, fontSize: 16)),
                if (productName.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product: $productName',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ingredients:',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(ingredients),
                      if (matchedAllergens.isNotEmpty) ...[
  const SizedBox(height: 20),
  Text(
    '⚠️ Allergens Found:',
    style: TextStyle(
      color: Colors.red[700],
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  const SizedBox(height: 8),
  Wrap(
    spacing: 8,
    children: matchedAllergens.map((allergen) {
      return Chip(
        label: Text(allergen),
        backgroundColor: Colors.red[100],
        labelStyle: const TextStyle(color: Colors.red),
      );
    }).toList(),
  ),
],

                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
} //end of _scanscreenclass

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
body: MobileScanner(
  onDetect: (BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        Navigator.pop(context, code);
      }
    }
  },
),
    );
  }
}