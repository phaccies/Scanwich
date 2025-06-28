import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future<void> fetchProduct() async {
    setState(() {
      isLoading = true;
      error = '';
      productName = '';
      ingredients = '';
    });

    const String testBarcode = '016000127319 '; // Skippy Peanut Butter
    final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$testBarcode.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final product = data['product'];

        setState(() {
          productName = product['product_name'] ?? 'Unknown Product';
          ingredients = product['ingredients_text'] ?? 'No ingredients listed.';
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
                  onPressed: fetchProduct,
                  child: const Text('Test API Call'),
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
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
