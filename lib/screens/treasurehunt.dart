import 'package:decimals/learnpage.dart';
import 'package:decimals/main.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

// Comment out the runApp functionaity; makes the practice page 
// to be a child page of the main.dart

// void main() {
//   runApp(DecimalTreasureHuntGame());
// }

class DecimalTreasureHuntGame extends StatelessWidget {
  const DecimalTreasureHuntGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const TreasureHuntScreen();
  }
}
  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Decimal Treasure Hunt',
  //     theme: ThemeData(primarySwatch: Colors.blue),
  //     home: TreasureHuntScreen(),
  //   );
  // }


class TreasureHuntScreen extends StatefulWidget {
  const TreasureHuntScreen({super.key});

  @override
  _TreasureHuntScreenState createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends State<TreasureHuntScreen> {
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int score = 0;
  late String number;
  late String question;
  late int correctAnswer;
  final List<String> places = ['Ones', 'Tens', 'Hundreds', 'Tenths', 'Hundredths', 'Thousandths'];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    number = (_random.nextDouble() * 1000).toStringAsFixed(3); // Generate a random decimal (e.g., 95.610)
    String selectedPlace = places[_random.nextInt(places.length)];
    Map<String, int> placeIndex = {
      'Ones': number.indexOf('.') - 1,
      'Tens': number.indexOf('.') - 2,
      'Hundreds': number.indexOf('.') - 3,
      'Tenths': number.indexOf('.') + 1,
      'Hundredths': number.indexOf('.') + 2,
      'Thousandths': number.indexOf('.') + 3,
    };

    int index = placeIndex[selectedPlace]!;
    correctAnswer = index >= 0 && index < number.length ? int.parse(number[index]) : 0;
    question = 'Find the digit in the $selectedPlace place of $number';
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _checkAnswer(int selected) async {
    if (selected == correctAnswer) {
      await _playSound('sounds/success.mp3');
      setState(() {
        score += 10;
        _generateQuestion();
      });
    } else {
      await _playSound('sounds/error.mp3');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Try Again', style: TextStyle(color: Colors.red)),
          content: Text("Oops! $selected is incorrect."),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green,title: const Text('Decimal Treasure Hunt!'), actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: (){ Navigator.popUntil(context, (route) => route.isFirst);},
            ),
            const SizedBox(width: 5),

          ]),
        )
      ]),
      body: Stack(
        children: [
      Positioned.fill(
      child: Image.asset(
      screenWidth > 1200
      ?
      'assets/matchitbackground.png': 'assets/b2.png',
        fit:  BoxFit.cover,
      ),
    ),
      Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue.shade100, Colors.blue.shade300]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Text(question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 1200 ? 5 : 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _checkAnswer(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, offset: const Offset(2, 2))],
                      ),
                      child: Center(child: Text('$index', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    ],
      ),
    );
  }
}
