import 'dart:math'; // Import for random selection
import 'package:flutter/material.dart';
import 'birdgame.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<Map<String, String>> questionSets = [
    {'.444': 'Thousandths', '.73': 'Hundredths', '61': 'Tens', '1.13': 'Tenths', '7842': 'Thousands', '5': 'Ones'},
    {'0.89': 'Hundredths', '92': 'Tens', '0.6': 'Tenths', '4567': 'Thousands', '3': 'Ones', '0.234': 'Thousandths'},
    {'0.15': 'Hundredths', '45': 'Tens', '1.2': 'Tenths', '6789': 'Thousands', '7': 'Ones', '0.098': 'Thousandths'},
  ]; // Multiple sets of questions

  late Map<String, String> correctPairs;
  late List<String> items;
  List<String> selectedItems = [];
  int score = 0;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _generateNewRound();
  }

  void _generateNewRound() {
    setState(() {
      int randomIndex = random.nextInt(questionSets.length);
      correctPairs = questionSets[randomIndex]; // Pick a random set
      items = correctPairs.entries.expand((e) => [e.key, e.value]).toList(); // Flatten into a list
      items.shuffle(); // Shuffle the items for randomness
      selectedItems.clear();
      score = score;
    });
  }

  void checkMatch() {
    if (selectedItems.length == 2) {
      final String first = selectedItems[0];
      final String second = selectedItems[1];

      if ((correctPairs[first] == second) || (correctPairs[second] == first)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Correct!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ));
        setState(() {
          score++;
          items.remove(first);
          items.remove(second);
        });

        if (items.isEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _showCompletionDialog();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Incorrect!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ));
      }
      selectedItems.clear();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Good Job! 🎉"),
          content: const Text("You matched all pairs! Play Next Round ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _generateNewRound(); // Generate a new question set
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
  Widget buildUnderlinedText(String text) {
    if (text == '.444') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '.44',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '4',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '.73') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '.7',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '3',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '61') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '6',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '1',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else if (text == '1.13') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '1.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '1',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '3',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else if (text == '7842') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '7',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '842',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else if (text == '5') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '5',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '0.89') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '0.8',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '9',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '92') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '9',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '2',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else if (text == '0.6') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '0.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '6',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '4567') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '4',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '567',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else if (text == '3') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '3',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '0.234') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '0.23',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '4',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '0.15') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '0.1',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '5',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '45') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '4',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '5',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else if (text == '1.2') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '1.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '2',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '6789') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '6',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '789',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else if (text == '7') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '7',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '0.098') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '0.09',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '8',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Play: Memory'),
        actions: [
          Text(
            "Score: $score",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Let's play Memory! Match each underlined value to the correct units:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              // padding: const EdgeInsets.only(left: 450.0, right: 450.0, bottom: 450.0),
              padding: EdgeInsets.only(
                left: screenWidth > 600 ? 450.0 : 16.0,
                right: screenWidth > 600 ? 450.0 : 16.0,
                bottom: screenWidth > 600 ? 450.0 : 16.0,
              ),

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final String item = items[index];
                final bool isSelected = selectedItems.contains(item);
                return GestureDetector(
                  onTap: () {
                    if (selectedItems.contains(item)) return;
                    setState(() {
                      selectedItems.add(item);
                    });
                    checkMatch();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.shade200 : Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.orange, width: 2)
                          : Border.all(color: Colors.purple, width: 1),
                    ),
                    alignment: Alignment.center,
                    child:item.contains('.') || (item == '61' || (item == '7842') || (item == '5')|| (item == '92') || (item == '4567')|| (item == '45')|| (item == '6789')|| (item == '7')|| (item == '3'))? buildUnderlinedText(item) : Text(
                      item,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
