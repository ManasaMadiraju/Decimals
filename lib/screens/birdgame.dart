// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class LizzieTheBirdGame extends StatefulWidget {
  const LizzieTheBirdGame({super.key});

  @override
  _LizzieTheBirdGameState createState() => _LizzieTheBirdGameState();
}

class _LizzieTheBirdGameState extends State<LizzieTheBirdGame> {
  String targetValue = "0.8"; // Correct answer
  String feedback = ""; // Feedback message (Correct or Incorrect)
  Color feedbackColor = Colors.transparent; // Feedback message color

  // Function to check the selected value
  void checkAnswer(String selectedValue) {
    setState(() {
      if (selectedValue == targetValue) {
        feedback = "Correct!";
        feedbackColor = Colors.green;
      } else {
        feedback = "Incorrect!";
        feedbackColor = Colors.red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play: Lizzie the Bird'),
        backgroundColor: Colors.green,
         actions: [
            IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
          ),
         ],
      ),
      body: buildGameScreen(),
    );
  }
  

  // Game Screen
  Widget buildGameScreen() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Help me choose the right fish to eat!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/bird.jpg', height: 100), // Bird image
              const SizedBox(height: 20),
              const Text(
                '8 Tenths',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  buildFishButton('0.08'),
                  buildFishButton('0.9'),
                  buildFishButton('0.8'), // Correct fish
                  buildFishButton('0.09'),
                ],
              ),
              const SizedBox(height: 20),
              // Feedback message
              Text(
                feedback,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: feedbackColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper function to build fish buttons
  Widget buildFishButton(String value) {
    return GestureDetector(
      onTap: () => checkAnswer(value),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.green.shade300,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: value == targetValue && feedback == "Correct!"
                ? Colors.pink
                : Colors.transparent,
            width: 4,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';


// class LizzieBirdGame extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.lightBlue[100],
    //   body: Stack(
    //     children: [
    //       // Background Image
    //       Positioned.fill(
    //         child: Image.asset(
    //           'assets/background.png', // Replace with your background image
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //       // Top Bar
    //       Positioned(
    //         top: 16,
    //         left: 16,
    //         right: 16,
    //         child: Container(
    //           height: 50,
    //           color: Colors.green[700],
    //           child: Center(
    //             child: Text(
    //               'Play: Lizzie the Bird',
    //               style: TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 20,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //       // Bird Image and Text Bubble
    //       Positioned(
    //         top: 120,
    //         left: 50,
    //         child: Column(
    //           children: [
    //             // Speech Bubble
    //             Container(
    //               padding: EdgeInsets.all(8),
    //               decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.circular(12),
    //                 border: Border.all(color: Colors.black, width: 1),
    //               ),
    //               child: Text(
    //                 'Help me chose the right fish to eat!',
    //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //               ),
    //             ),
    //             SizedBox(height: 16),
    //             // Bird
    //             Image.asset(
    //               'assets/bird.png', // Replace with your bird image
    //               width: 100,
    //               height: 100,
    //             ),
    //           ],
    //         ),
    //       ),
    //       // Question Text
    //       Positioned(
    //         top: 280,
    //         left: 0,
    //         right: 0,
    //         child: Center(
    //           child: Text(
    //             '8 Tenths',
    //             style: TextStyle(
    //               fontSize: 32,
    //               fontWeight: FontWeight.bold,
    //               color: Colors.purple,
    //             ),
    //           ),
    //         ),
    //       ),
    //       // Fish Options
    //       Positioned(
    //         bottom: 80,
    //         left: 20,
    //         right: 20,
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: [
    //             FishOption(label: '0.08'),
    //             FishOption(label: '0.9'),
    //             FishOption(label: '0.8'), // Correct answer
    //             FishOption(label: '0.09'),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
//   }
// }

// class FishOption extends StatelessWidget {
//   final String label;

//   FishOption({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Image.asset(
//           'assets/fish.png', // Replace with your fish image
//           width: 80,
//           height: 80,
//         ),
//         SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }
