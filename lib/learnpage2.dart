import 'package:decimals/learnpage.dart';
import 'package:flutter/material.dart';
import 'screens/reading_decimals_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class LearnPage2 extends StatefulWidget {
  const LearnPage2({super.key});

  @override
  _LearnPageState2 createState() => _LearnPageState2();
}

class _LearnPageState2 extends State<LearnPage2> {
  final Map<String, String> originalTexts = {
    'h1':'Place Values in Decimals',
    'h2':'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.\n'
  '\n Example : In 0.25, 2 is in the tenths place, and 5 is in the hundredths place.',
    'NextPage': 'Next Page'
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
        translated = false; // Mark as untranslated
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Decimals'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
             icon: const Icon(Icons.arrow_forward_rounded),
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                     builder: (context) =>
                         const ReadingDecimalScreen()),  
               );
             },
           ),
          // Previous button - Goes back to the LearnPage
           IconButton(
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => LearnPage()),
                );
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: translateTexts,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 50,right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Text(
                  translated
                      ? translatedTexts['h1'] ?? originalTexts['h1']!
                      : originalTexts['h1']!,
                  style: const TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
            ),
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                translated
                    ? translatedTexts['h2'] ?? originalTexts['h2']!
                    : originalTexts['h2']!,
                style: const TextStyle(fontSize: 22, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 40),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/decimal2.png',
                  width: 250,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Button color
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(10),
                   ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReadingDecimalScreen(),
                      ),
                    );
                  },
                  child: Text(
                    translated
                        ? translatedTexts['NextPage'] ?? originalTexts['NextPage']!
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