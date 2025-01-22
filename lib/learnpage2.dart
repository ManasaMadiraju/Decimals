import 'package:flutter/material.dart';
import 'screens/reading_decimals_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class LearnPage2 extends StatefulWidget {
  @override
  _LearnPageState2 createState() => _LearnPageState2();
}

class _LearnPageState2 extends State<LearnPage2> {
  final Map<String, String> originalTexts = {
    'h1':'Place Values in Decimals',
    'h2':'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.'
  'Example : In 0.25, 2 is in the tenths place, and 5 is in the hundredths place.',
    'NextPage': 'Next Page'
  };
  Map<String, String> translatedTexts = {};
  bool translated = false;
  Future<void> translateTexts() async {
    if (!translated) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/translate'),
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
                         ReadingDecimalScreen()),  
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center( child:  Text(
              translated
                  ? translatedTexts['h1'] ?? originalTexts['h1']!
                  : originalTexts['h1']!,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            ),
            const SizedBox(height: 20),
            Text(
              translated
                  ? translatedTexts['h2'] ?? originalTexts['h2']!
                  : originalTexts['h2']!,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 20),
            Center(

            child: Image.asset(
              'assets/decimal2.png', // Add your own image path
              width: 200,
              height: 100,
              fit: BoxFit.cover,
            ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Aligns the button to the left
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReadingDecimalScreen()),
                    );
                  },
                  child: Text(translated
                      ? translatedTexts['NextPage'] ?? originalTexts['NextPage']!
                      : originalTexts['NextPage']!,
                    style: const TextStyle(fontSize: 28),),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }
}