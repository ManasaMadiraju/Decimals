import 'package:flutter/material.dart';
import 'reading_decimals_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// this is the Learn Decimal page
class placevalueexample extends StatefulWidget {
  const placevalueexample({super.key});

  @override
  _placevalueexample createState() => _placevalueexample();
}

class _placevalueexample extends State<placevalueexample> {
  int currentIndex = 0;
  final List<Map<String,String>> examples =[
    {
      'image': 'assets/img.png',
      'text': 'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.\n'
          '\n Example : In 34.28, 2 is in the tenths place, and 8 is in the hundredths place.',
    },
    { 'image': 'assets/img_1.png',
      'text': 'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.\n'
          '\n Example :  In 162.293, 2 is in the tenths place, and 9 is in the hundredths place and 3 is in the thousandths place.',
    },
    { 'image': 'assets/img_2.png',
      'text': 'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.\n'
          '\n Example :  In 9.13, 1 is in the tenths place, and 3 is in the hundredths place.',
    },
    { 'image': 'assets/img_3.png',
      'text': 'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.\n'
          '\n Example :  In 300.5, 5 is in the tenths place.',
    },
    { 'image': 'assets/img_4.png',
      'text': 'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.\n'
          '\n Example :  In 5206.485, 4 is in the tenths place, and 8 is in the hundredths place and 5 is in the thousandths place.',
    },
    { 'image': 'assets/img_5.png',
      'text': 'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.\n'
          '\n Example :  In 6214.4, 4 is in the tenths place.',
    },
    { 'image': 'assets/img_6.png',
      'text': 'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.\n'
          '\n Example :  In 1.88, 8 is in the tenths place, and 8 is in the hundredths place.',
    }
  ];
  final Map<String, String> originalTexts = {
    'h1': 'Place Values in Decimals',
    'NextPage': 'Next',
    'Back': 'Back'
  };
  // Map<String, String> translatedTexts = {};
  bool translated = false;
  Future<void> translateTexts() async {
    if (!translated) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'texts': examples.map((e) => e['text']).toList()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
            for (int i = 0; i < examples.length; i++){
              examples[i]['translatedText'] = data['translations'][i];
            }
            translated = true;
        });
      } else {
        print('Failed to fetch translations: ${response.statusCode}');
      }
    } else {
      setState(() {
        for (var example in examples) {
          example.remove('translatedText');
        }
        translated = false; // Mark as untranslated
      });
    }
  }
  void _nextExample() {
    setState(() {
      if (currentIndex < examples.length - 1) {
        currentIndex++;
      } else {
        // Optionally loop back or navigate away
        currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final example=examples[currentIndex];
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
                    builder: (context) => const ReadingDecimalScreen()),
              );
            },
          ),
          // Previous button - Goes back to the LearnPage
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                // translated
                //     ? translatedTexts['h1'] ?? originalTexts['h1']!
                originalTexts['h1']!,
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
                    ? example['translatedText'] ?? example['text']!
                    : example['text']!,
                style: const TextStyle(fontSize: 22, color: Colors.black87),
              )
            ),
            const SizedBox(height: 40),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  example['image']!,
                  width: 450,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                     originalTexts['Back']!,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _nextExample,
                  child: Text(
                     originalTexts['NextPage']!,
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
