import 'package:flutter/material.dart';
import 'screens/reading_decimals_screen.dart';

class LearnPage2 extends StatelessWidget {
  const LearnPage2({super.key});

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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center( child:  Text(
              'Place Values in Decimals',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Each number after the decimal point has a place value: tenths, hundredths, and thousandths.'
              'Example : In 0.25, 2 is in the tenths place, and 5 is in the hundredths place.',
              style: TextStyle(fontSize: 18),
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
                  child: const Text('Next Page'),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }
}