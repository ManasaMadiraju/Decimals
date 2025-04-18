import 'package:decimals/GameSelectionDialog.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PlaceValueScreen1 extends StatefulWidget {
  const PlaceValueScreen1({super.key});

  @override
  _PlaceValueScreenState1 createState() => _PlaceValueScreenState1();
}

class _PlaceValueScreenState1 extends State<PlaceValueScreen1> {
  final List<Map<String, String>> questions = [
    {
      '1': 'Tens',
      '7': 'Ones',
      '.': 'Decimal',
      '6': 'Tenths',
      '2': 'Hundredths',
      '5': 'Thousandths',
    },
    {
      '5': 'Tens',
      '8': 'Ones',
      '.': 'Decimal',
      '3': 'Tenths',
      '2': 'Hundredths',
    },
    {
      '0': 'Ones',
      '.': 'Decimal',
      '7': 'Tenths',
      '2': 'Hundredths',
      '1': 'Thousandths',
    },
    {
      '8': 'Hundreds',
      '6': 'Tens',
      '4': 'Ones',
    },
  ];

  final List<String> extraOptions = [
    'Tens',
    'Ones',
    'Tenths',
    'Hundredths',
    'Thousandths',
    'Seven',
    'Thousands',
    'Hundreds',
    'Teen',
    'Oneths',
    'Sevenths',
    'Decimal',
  ];

  final Map<String, String> draggedItems = {};
  final Map<String, bool> feedback = {};
  int score = 0;
  int currentQuestionIndex = 0;

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown
  ];

  // Method to navigate to a specific page when back button is pressed
  void _navigateToCustomPage() {
    // Navigate to a specific page - replace BirdGameScreen() with your desired destination
    Navigator.of(context).pop(
      MaterialPageRoute(builder: (context) => GameSelectionDialog()),
    );
  }

  // Method to handle home button press
  void _navigateToHome() {
    // Navigate to home screen
    Navigator.popUntil(context, (route) => route.isFirst);
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool shouldRotate = screenWidth < 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text('Match it !        : Score $score'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToCustomPage,
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body:Stack(
        children: [
      Positioned.fill(
      child: Image.asset(
      screenWidth > 1200
      ?
      'assets/matchitbackground.png': 'assets/l2.png',
        fit:  BoxFit.cover,
      ),
    ), shouldRotate
          ? RotatedBox(
              quarterTurns: 3, // Rotate the screen by 90 degrees
              child: _buildGameContent(),
            )
          : _buildGameContent(),
    ],
    ),
    );
  }

  Widget _buildGameContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Match Each Number with its Place Value:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: questions[currentQuestionIndex].keys.map((number) {
              int colorIndex = questions[currentQuestionIndex]
                      .keys
                      .toList()
                      .indexOf(number) %
                  colors.length;
              return Column(
                children: [
                  _buildColoredNumber(number, colors[colorIndex]),
                  const SizedBox(height: 10),
                  _buildDragTarget(number),
                ],
              );
            }).toList(),
          ),
          // const SizedBox(height: 40),
          // _buildFeedbackSection(),
          const SizedBox(height: 20),
          _buildDraggableOptions(),
        ],
      ),
    );
  }

  Widget _buildDraggableOptions() {
    final shuffledOptions = [...extraOptions]..shuffle(Random());
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: shuffledOptions.map((value) => _buildDraggable(value)).toList(),
    );
  }

  Widget _buildColoredNumber(String number, Color color) {
    return Text(
      number,
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildDraggable(String value) {
    return Draggable<String>(
      data: value,
      feedback: Material(
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[300],
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[200],
        child: Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[300],
        child: Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDragTarget(String key) {
    return DragTarget<String>(
      onAcceptWithDetails: (value) {
        setState(() {
          if (questions[currentQuestionIndex][key] == value.data) {
            if (!draggedItems.containsKey(key)) {
              score++;
            }
            draggedItems[key] = value.data;
            feedback[key] = true;
          } else {
            feedback[key] = false;
          }

          if (score == questions[currentQuestionIndex].length) {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                currentQuestionIndex =
                    (currentQuestionIndex + 1) % questions.length;
                draggedItems.clear();
                feedback.clear();
                score = 0;
              });
            });
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: draggedItems[key] != null ? Colors.green[100] : Colors.white,
          ),
          alignment: Alignment.center,
          child: draggedItems[key] != null
              ? Text(
                  draggedItems[key]!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                )
              : const Text(
                  'Drop here',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
        );
      },
    );
  }
}
