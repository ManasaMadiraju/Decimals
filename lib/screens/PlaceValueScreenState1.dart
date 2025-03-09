import 'package:decimals/screens/treasurehunt.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PlaceValueScreen1 extends StatefulWidget {
  const PlaceValueScreen1({super.key});

  @override
  _PlaceValueScreenState1 createState() => _PlaceValueScreenState1();
}

class _PlaceValueScreenState1 extends State<PlaceValueScreen1> {
  final List<Map<String, String>> questions =[ {
    '1': 'Tens',
    '7': 'Ones',
    '.':'Decimal',
    '6': 'Tenths',
    '2': 'Hundredths',
    '5': 'Thousandths',
  },{
    '5': 'Tens',
    '8': 'Ones',
    '.':'Decimal',
    '3': 'Tenths',
    '2': 'Hundredths',
  },
    {
      '0': 'Ones',
      '.':'Decimal',
      '7': 'Tenths',
      '2': 'Hundredths',
      '1': 'Thousandths',
    },
    {
      '8':'Hundreds',
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
  final Map<String, bool> feedback = {

  };
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
  @override
  Widget build(BuildContext context) {
    // Combine and shuffle options
    final Map<String, String> currentQuestion = questions[currentQuestionIndex];
    final shuffledOptions = [...extraOptions]..shuffle(Random());
    return Scaffold(
      appBar: AppBar(
        title: Text('Match it !        : Score $score'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Match Each Number with its Place Value:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Numbers with Drop Targets Below
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: currentQuestion.keys.map((number) {
                int colorIndex = currentQuestion.keys.toList().indexOf(number) % colors.length;
                return Column(
                  children: [
                    _buildColoredNumber(number, colors[colorIndex]),
                    const SizedBox(height: 10),
                    _buildDragTarget(number),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            // Feedback Section
            Column(
              children: feedback.keys.map((key) {
                return Text(
                  feedback[key]! ? "Correct for $key!" : "Incorrect for $key!",
                  style: TextStyle(
                    color: feedback[key]! ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Draggable Options
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: shuffledOptions.map((value) => _buildDraggable(value)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for colored numbers
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

  // Widget for draggable options
  Widget _buildDraggable(String value) {
    return Draggable<String>(
      data: value,
      feedback: Material(
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[300],
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[200],
        child: Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[300],
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

          // Move to next question when 5 correct matches are made
          if (score == questions[currentQuestionIndex].length) {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                currentQuestionIndex = (currentQuestionIndex + 1) % questions.length;
                draggedItems.clear();
                feedback.clear();
                score = 0; // Reset score for the new question
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
            color: draggedItems[key] != null
                ? Colors.green[100]
                : Colors.white,
          ),
          alignment: Alignment.center,
          child: draggedItems[key] != null
              ? Text(
            draggedItems[key]!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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