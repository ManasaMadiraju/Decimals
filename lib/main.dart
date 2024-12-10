import 'package:decimals/screens/memorygameapp.dart';
import 'package:flutter/material.dart';
import 'package:decimals/screens/practice1.dart';
import 'learnpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => DecimalsPage(),
        '/learn': (context) => const LearnPage(),
        '/play': (context) => const MemoryGameScreen(),
        '/practice': (context) => PlaceValueScreen(),
      },
    );
  }
}

class DecimalsPage extends StatelessWidget {
  const DecimalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Decimals',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton('Learn', Colors.green.shade600, context, '/learn'),
                  const SizedBox(height: 40),
                  _buildButton('Play', Colors.green.shade300, context, '/play'),
                  const SizedBox(height: 40),
                  _buildButton('Practice', Colors.green.shade600, context, '/practice'),
                ],
              ),
            ),
          ),
          Image.asset(
            'assets/kids.jpeg', // Replace with your image path
            height: 250,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, BuildContext context, String route) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
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
    );
  }
}
