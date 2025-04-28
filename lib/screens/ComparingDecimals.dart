import 'package:flutter/material.dart';

class ComparingDecimalsPage extends StatelessWidget {
  const ComparingDecimalsPage({super.key});

  void _navigateToHome(BuildContext context) {
    // Navigate to home screen
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
          const Icon(Icons.arrow_forward),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _navigateToHome(context),
          ),
          // Icon(Icons.home),
          const SizedBox(width: 10),
          const Icon(Icons.translate),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Comparing Decimals',
              style: TextStyle(
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
              child: const Text(
                // 'When we compare decimals, we look at each number from left to right:\n\n'
                // '• First, compare the whole numbers.\n'
                // '• If they are the same, look at the tenths.\n'
                // '• Then check hundredths if needed.\n\n'
                '👉 Example: Which is bigger: 3.45 or 3.5?\n'
                '- Whole numbers: 3 and 3 → same!\n'
                '- Tenths: 4 vs 5 → 5 is bigger!\n'
                'So, 3.45 is smaller than 3.5\n\n'
                '📌 Tip: You can write 3.5 as 3.50 to compare easily.\n'
                'Now compare: 3.45 < 3.50',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/comparingdecimals.png', // add image in assets
              height: 200,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              // child: ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFF009688),
              //   ),
              //   onPressed: () {
              //     // Add navigation logic here
              //   },
              //   child: const Text('Next Page'),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
