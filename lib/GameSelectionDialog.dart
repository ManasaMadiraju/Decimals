import 'package:flutter/material.dart';
import 'package:decimals/screens/birdgame.dart';
import 'package:decimals/screens/memorygameapp.dart';
import 'package:decimals/screens/PlaceValueScreenState1.dart';
import 'package:decimals/screens/ChooseItGameScreen.dart';

class GameSelectionDialog extends StatelessWidget {
  const GameSelectionDialog({super.key});

  void _navigateToGame(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero, // Remove default padding
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/play.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:  Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Choose a Game',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    _buildGameButton(context, '🃏 Match the Tile', MemoryGameScreen(), Colors.blue),
                    _buildGameButton(context, '🐦 Lizzie Bird', LizzieTheBirdGame(), Colors.green),
                    _buildGameButton(context, '🎯 Decimal Place Value Puzzle', PlaceValueScreen1(), Colors.orange),
                    _buildGameButton(context, '🎤 Choose It', ChooseItGameScreen(), Colors.purple),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: (){ Navigator.popUntil(context, (route) => route.isFirst);},
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(BuildContext context, String title, Widget screen, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => _navigateToGame(context, screen),
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}