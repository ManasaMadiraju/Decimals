import 'package:decimals/screens/FractionsToDecimals.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ComparingDecimalsPage extends StatefulWidget {
  const ComparingDecimalsPage({super.key});

  @override
  State<ComparingDecimalsPage> createState() => _ComparingDecimalsPageState();
}

class _ComparingDecimalsPageState extends State<ComparingDecimalsPage> {
  final Map<String, String> originalTexts = {
    'title': 'Comparing Decimals',
    'body': '👉 Example: Which is bigger: 3.45 or 3.5?\n'
        '- Whole numbers: 3 and 3 → same!\n'
        '- Tenths: 4 vs 5 → 5 is bigger!\n'
        'So, 3.45 is smaller than 3.5\n\n'
        '📌 Tip: You can write 3.5 as 3.50 to compare easily.\n'
        'Now compare: 3.45 < 3.50',
    'NextPage': 'Next Page',
    'Back': 'Back'
  };

  Map<String, String> translatedTexts = {};
  bool translated = false;

  Future<void> translateTexts() async {
    if (!translated) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'texts': originalTexts.values.toList()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          translatedTexts = {
            for (int i = 0; i < originalTexts.keys.length; i++)
              originalTexts.keys.elementAt(i): data['translations'][i]
          };
          translated = true;
        });
      } else {
        print('Failed to fetch translations: ${response.statusCode}');
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false;
      });
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Comparing Decimals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _navigateToHome(context),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: translateTexts,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Column(
          children: [
            Text(
              translated
                  ? translatedTexts['title'] ?? originalTexts['title']!
                  : originalTexts['title']!,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                translated
                    ? translatedTexts['body'] ?? originalTexts['body']!
                    : originalTexts['body']!,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/comparingdecimals.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            // ✅ Added Next Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    translated
                        ? translatedTexts['Back'] ?? originalTexts['Back']!
                        : originalTexts['Back']!,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FractionsToDecimalsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    translated
                        ? translatedTexts['NextPage'] ??
                            originalTexts['NextPage']!
                        : originalTexts['NextPage']!,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
