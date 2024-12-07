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
      backgroundColor: Color(0xFF34E1FF),

    );
  }

//   Widget buildGameScreen() {
//     return Stack(
//       children: [
//         // Background Image
//         Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height*0.90,
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/backgroundlake.jpg"),
//               fit: BoxFit.cover, // Cover the entire container
//             ),
//           ),
//         ),
//         // Content on top of the background
//         Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns items at top and bottom
//           children: [
//             // Top Section
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Help me choose the right fish to eat!',
//                   style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 30),
//                 SizedBox(
//                   height: 200, // Adjust the size
//                   width: 250,
//                   child: Image.asset(
//                     'assets/bird.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//     const SizedBox(height: 30),
//                 const Text(
//                   '8 Tenths',
//                   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                 ),
//
//                 const SizedBox(height:230),
//               ],
//             ),
//             // const Spacer(),
//
//             // Wrap Section
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Wrap(
//                 spacing: 20,
//                 runSpacing: 20,
//                 children: [
//                   buildFishButton('0.08'),
//                   buildFishButton('0.9'),
//                   buildFishButton('0.8'), // Correct fish
//                   buildFishButton('0.09'),
//                 ],
//               ),
//             ),
//
//             // Feedback Text Below Wrap
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Text(
//                 feedback,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: feedbackColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//
//   // Helper function to build fish buttons
//   Widget buildFishButton(String value) {
//     return GestureDetector(
//       onTap: () => checkAnswer(value),
//       child: Container(
//         width: 150,
//         height: 90,
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           border: Border.all(
//             color: value == targetValue && feedback == "Correct!"
//                 ? Colors.pink
//                 : Colors.transparent,
//             width: 4,
//           ),
//           image: DecorationImage(
//             image: AssetImage("assets/orangefish.png"), // Replace with your image path
//             fit: BoxFit.fill,
//           ),
//         ),
//
//         alignment: Alignment.center,
//         child: Text(
//           value,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
  Widget buildGameScreen() {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Stack(
      children: [
        // Background Image
        Container(
          width: screenWidth,
          height: screenHeight * 0.90,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backgroundlake.jpg"),
              fit: BoxFit.cover, // Cover the entire container
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // Aligns items at top and bottom
          children: [
            // Top Section
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Help me choose the right fish to eat!',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.15),
                SizedBox(
                  height: screenHeight * 0.2,

                  width: screenWidth * 0.35,

                  child: Image.asset(
                    'assets/bird.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: screenHeight * 0.2),
                const Text(
                  '8 Tenths',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),

            // Wrap Section
            Wrap(
              spacing: screenWidth * 0.05,
              runSpacing: screenHeight * 0.02,
              children: [
                buildFishButton('0.08', screenWidth, screenHeight),
                buildFishButton('0.9', screenWidth, screenHeight),
                buildFishButton('0.8', screenWidth, screenHeight),
                // Correct fish
                buildFishButton('0.09', screenWidth, screenHeight),
              ],
            ),

            // Feedback Text Below Wrap
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              child: Text(
                feedback,
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                  color: feedbackColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget buildFishButton(String value, double screenWidth,
      double screenHeight) {
    return GestureDetector(
      onTap: () => checkAnswer(value),
      child: Container(
        width: screenWidth * 0.2,
        // Responsive width
        height: screenHeight * 0.15,
        // Responsive height
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: value == targetValue && feedback == "Correct!"
                ? Colors.pink
                : Colors.transparent,
            width: screenWidth * 0.01, // Responsive border width
          ),
          image: DecorationImage(
            image: AssetImage("assets/orangefish.png"),
            // Replace with your image path
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(
            fontSize: screenHeight * 0.02, // Responsive font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
