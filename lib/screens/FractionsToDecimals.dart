// import 'package:flutter/material.dart';

// void main() {
//   runApp(const FractionsToDecimalsApp());
// }

// class FractionsToDecimalsApp extends StatelessWidget {
//   const FractionsToDecimalsApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Converting Fractions to Decimals',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         scaffoldBackgroundColor: Colors.grey.shade50,
//       ),
//       home: const FractionsToDecimalsScreen(),
//     );
//   }
// }

// class FractionsToDecimalsScreen extends StatelessWidget {
//   const FractionsToDecimalsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Converting Fractions to Decimals'),
//         elevation: 2,
//         backgroundColor: Colors.green.shade700,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Instruction Box
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade50,
//                 borderRadius: BorderRadius.circular(12.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade300,
//                     blurRadius: 6,
//                     offset: const Offset(2, 2),
//                   ),
//                 ],
//               ),
//               child: const Text(
//                 'To convert fractions to decimals:\n'
//                 '1️⃣ Divide the numerator by the denominator.\n'
//                 '2️⃣ Write the result as a decimal.\n'
//                 '3️⃣ If necessary, round the decimal to the desired place value.',
//                 style: TextStyle(
//                   fontSize: 16.0,
//                   height: 1.5,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 25),

//             // Examples Box
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(12.0),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Examples:',
//                     style: TextStyle(
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueAccent,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   exampleRow('1/2', '0.5'),
//                   exampleRow('3/4', '0.75'),
//                   exampleRow('7/8', '0.875'),
//                   exampleRow('5/6', '0.833…'),
//                   exampleRow('2/5', '0.4'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Next Page Button
//             Align(
//               alignment: Alignment.centerRight,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 25.0, vertical: 12.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   elevation: 3,
//                 ),
//                 onPressed: () {
//                   // Navigate to next page or lesson
//                 },
//                 child: const Text(
//                   'Next Page',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget exampleRow(String fraction, String decimal) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             fraction,
//             style: const TextStyle(
//               fontSize: 16.0,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
//             decoration: BoxDecoration(
//               color: Colors.green.shade100,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               decimal,
//               style: const TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const FractionsToDecimalsApp());
}

class FractionsToDecimalsApp extends StatelessWidget {
  const FractionsToDecimalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converting Fractions to Decimals',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: const FractionsToDecimalsScreen(),
    );
  }
}

class FractionsToDecimalsScreen extends StatefulWidget {
  const FractionsToDecimalsScreen({super.key});

  @override
  State<FractionsToDecimalsScreen> createState() =>
      _FractionsToDecimalsScreenState();
}

class _FractionsToDecimalsScreenState extends State<FractionsToDecimalsScreen> {
  final Map<String, String> originalTexts = {
    'title': 'Converting Fractions to Decimals',
    'instructions':
        'To convert fractions to decimals:\n'
        '1️⃣ Divide the numerator by the denominator.\n'
        '2️⃣ Write the result as a decimal.\n'
        '3️⃣ If necessary, round the decimal to the desired place value.',
    'examples': 'Examples:',
    'NextPage': 'Next Page',
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
        title: Text(originalTexts['title']!),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              translated
                  ? translatedTexts['title'] ?? originalTexts['title']!
                  : originalTexts['title']!,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Instruction Box
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                translated
                    ? translatedTexts['instructions'] ??
                        originalTexts['instructions']!
                    : originalTexts['instructions']!,
                style: const TextStyle(
                  fontSize: 16.0,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Examples Box
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translated
                        ? translatedTexts['examples'] ??
                            originalTexts['examples']!
                        : originalTexts['examples']!,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  exampleRow('1/2', '0.5'),
                  exampleRow('3/4', '0.75'),
                  exampleRow('7/8', '0.875'),
                  exampleRow('5/6', '0.833…'),
                  exampleRow('2/5', '0.4'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Next Page Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  // Navigate to another lesson
                },
                child: Text(
                  translated
                      ? translatedTexts['NextPage'] ?? originalTexts['NextPage']!
                      : originalTexts['NextPage']!,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exampleRow(String fraction, String decimal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            fraction,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              decimal,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




