import 'package:flutter/material.dart';
import 'learnpage2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  _LearnPageState createState() => _LearnPageState();
}
class _LearnPageState extends State<LearnPage> {
  final Map<String, String> originalTexts = {
    'heading': 'What are Decimals?',
    'body':
    'Decimals are a way of expressing numbers that are not whole numbers. They are numbers with a dot, called a decimal point.',
    'example': 'Decimal Example: 0.1 means one-tenth.',
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
         title: const Text('Introduction'),
         backgroundColor: Colors.green,
         actions: [
            IconButton(
             icon: const Icon(Icons.arrow_forward_rounded),
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                     builder: (context) =>
                         const LearnPage2()),
               );
             },
           ),
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
       // body: Padding(
       //   padding: const EdgeInsets.all(16.0),
       //   child: Column(
       //     crossAxisAlignment: CrossAxisAlignment.start,
       //     children: [
       //       Center(
       //       child:  Text(
       //         translated
       //             ? translatedTexts['heading'] ?? originalTexts['heading']!
       //             : originalTexts['heading']!,
       //         style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
       //       ),
       //       ),
       //       const SizedBox(height: 20),
       //       Text(
       //         translated? translatedTexts['body'] ?? originalTexts['body']!
       //             : originalTexts['body']!,
       //         style: const TextStyle(fontSize: 18),
       //       ),
       //       const SizedBox(height: 20),
       //        Text(
       //         translated
       //             ? translatedTexts['example'] ?? originalTexts['example']!
       //             : originalTexts['example']!,
       //         style: const TextStyle(fontSize: 18),
       //       ),
       //       const SizedBox(height: 30),
       //        Center(
       //        child: Image.asset(
       //         'assets/decimal1.png',
       //         width: 200,
       //         height: 100,
       //         fit: BoxFit.cover,
       //       ),
       //        ),
       //       const SizedBox(height: 20),
       //       Row(
       //         mainAxisAlignment: MainAxisAlignment.end, // Aligns the button to the left
       //         children: [
       //           ElevatedButton(
       //             onPressed: () {
       //               Navigator.push(
       //                 context,
       //                 MaterialPageRoute(builder: (context) =>  const LearnPage2()),
       //               );
       //             },
       //             child:  Text(translated
       //                 ? translatedTexts['NextPage'] ?? originalTexts['NextPage']!
       //                 : originalTexts['NextPage']!,
       //               style: const TextStyle(fontSize: 18),),
       //           ),
       //         ],
       //       ),
       //     ],
       //   ),
       // ),
       body: Padding(
         padding: const EdgeInsets.only(left: 50, right: 50),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             // Heading
             Center(
               child: Text(
                 translated
                     ? translatedTexts['heading'] ?? originalTexts['heading']!
                     : originalTexts['heading']!,
                 style: const TextStyle(
                   fontSize: 50,
                   fontWeight: FontWeight.bold,
                   color: Colors.teal,
                 ),
                 textAlign: TextAlign.center,
               ),
             ),

             const SizedBox(height: 50),

             // Description Text
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.grey[200], // Light background for better contrast
                 borderRadius: BorderRadius.circular(10),
               ),
               child: Text(
                 translated ? translatedTexts['body'] ?? originalTexts['body']!
                     : originalTexts['body']!,
                 style: const TextStyle(fontSize: 18, height: 1.5),
                 textAlign: TextAlign.justify,
               ),
             ),

             const SizedBox(height: 20),

             // Example Text
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.blue[50], // Slightly different background
                 borderRadius: BorderRadius.circular(10),
               ),
               child: Text(
                 translated
                     ? translatedTexts['example'] ?? originalTexts['example']!
                     : originalTexts['example']!,
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                 textAlign: TextAlign.justify,
               ),
             ),

             const SizedBox(height: 60),

             // Image Centered
             Center(
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(15),
                 child: Image.asset(
                   'assets/decimal1.png',
                   width: 320,
                   height: 120,
                   fit: BoxFit.cover,
                 ),
               ),
             ),

             const SizedBox(height: 60),

             // Next Page Button
             Align(
               alignment: Alignment.centerRight,
               child: ElevatedButton(
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
                     MaterialPageRoute(builder: (context) => const LearnPage2()),
                   );
                 },
                 child: Text(
                   translated
                       ? translatedTexts['NextPage'] ?? originalTexts['NextPage']!
                       : originalTexts['NextPage']!,
                   style: const TextStyle(fontSize: 18, color: Colors.white),
                 ),
               ),
             ),
           ],
         ),
       ),

     );
   }
}