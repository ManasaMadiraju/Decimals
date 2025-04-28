import 'package:flutter/material.dart';
import 'learnpage.dart';
import 'GameSelectionDialog.dart';
import 'package:decimals/screens/treasurehunt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decimal App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const DecimalsPage(),
        '/learn': (context) =>  const LearnPage(),
        '/play': (context) => const GameSelectionDialog(),
        '/practice': (context) =>  DecimalTreasureHuntGame(),
      },
    );
  }
}

class DecimalsPage extends StatelessWidget {
  const DecimalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,

        title: const Text(
          'Decimals',
          style: TextStyle(color: Colors.white)
        ),
      ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/demo1.jpg',
                      width: screenWidth> 1200 ? screenWidth*0.55: screenWidth, // Set image width
                      height: screenHeight*0.95, // Set image height
                      fit:screenWidth> 600 ? BoxFit.contain: BoxFit.fitWidth,
                      alignment: Alignment.center,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height:400),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButton('Learn', Colors.green.shade600, context, '/learn',screenWidth,screenHeight),
                            _buildButton('Play', Colors.green.shade600, context, '/play',screenWidth,screenHeight),
                            _buildButton('Practice', Colors.green.shade600, context, '/practice',screenWidth,screenHeight),
                          ],
                        ),
                        Text(
                          "LET'S LEARN DECIMALS",
                          style:TextStyle(
                            fontSize: 28, // Adjust size
                            fontWeight: FontWeight.bold, // Make it stand out
                            color: Colors.white, // Keep white for contrast
                            letterSpacing: 1.5, // Slight spacing for readability
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildButton(String text, Color color, BuildContext context, String route,double screenWidth, double screenHeight) {
    return SizedBox(
      width: screenWidth< 500?120: 150,
      height: 150,
      child:  Align( alignment: Alignment.center,
        child:  ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),
      ),
    );
  }
}
