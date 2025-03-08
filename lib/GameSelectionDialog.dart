import 'package:flutter/material.dart';
import 'package:decimals/screens/practice1.dart';
import 'package:decimals/screens/birdgame.dart';
import 'package:decimals/screens/memorygameapp.dart';
import 'package:decimals/screens/PlaceValueScreenState1.dart';
import 'package:decimals/screens/ChooseItGameScreen.dart';
class GameSelectionDialog extends StatelessWidget {
  const GameSelectionDialog({super.key});

  void _navigateToGame(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close the dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95), // Slight transparency
          borderRadius: BorderRadius.circular(20), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Soft shadow
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildGameButton(context, '🃏 Memory Game', MemoryGameScreen(), Colors.blue),
            _buildGameButton(context, '🐦 Lizzie Bird', LizzieTheBirdGame(), Colors.green),
            _buildGameButton(context, '🎯 Match It', PlaceValueScreen1(), Colors.orange),
            _buildGameButton(context, '🎤 Choose It', ChooseItGameScreen(), Colors.purple),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.red),
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