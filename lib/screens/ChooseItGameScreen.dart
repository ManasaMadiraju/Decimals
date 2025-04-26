import 'package:decimals/GameSelectionDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:decimals/custom_dialog.dart'; 

class ChooseItGameScreen extends StatefulWidget {
  const ChooseItGameScreen({super.key});

  @override
  _ChooseItGameScreenState createState() => _ChooseItGameScreenState();
}

class _ChooseItGameScreenState extends State<ChooseItGameScreen> {
  // adds audio for the correct answer 
  final FlutterTts _flutterTts = FlutterTts();
  final List<Map<String, dynamic>> questions = [
    {
      'number': 12.7,
      'description': 'Twelve and seven tenths',
      'options': [
        'Twelve and seven hundredths',
        'Twelve and seventy hundredths',
        'Eleven and seven tenths',
        'Twelve and seven tenths', // Correct answer
      ]
    },
    {
      'number': 38.29,
      'description': 'Thirty Eight and Twenty Nine Hundredths',
      'options': [
        'Thirty Eight and Twenty Eight Hundredths',
        'Thirty Seven and Twenty Nine Hundredths',
        'Thirty Nine and Twenty Nine Hundredths',
        'Thirty Eight and Twenty Nine Hundredths', // Correct answer
      ]
    },
    {
      'number': 453.01,
      'description': 'Four Hundred Fifty Three and One Hundredths',
      'options': [
        'Four Hundred Fifty Three and One Thousandth',
        'Four Hundred Fifty Four and One Hundredths',
        'Four Hundred Fifty Three and Ten Hundredths',
        'Four Hundred Fifty Three and One Hundredths', // Correct answer
      ]
    },
    {
      'number': 0.75,
      'description': 'Seventy Five Hundredths',
      'options': [
        'Seventy Five Tenths',
        'Seventy Five Thousandths',
        'Seven and Fifty Hundredths',
        'Seventy Five Hundredths', // Correct answer
      ]
    },
    {
      'number': 5.6,
      'description': 'Five and Six Tenths',
      'options': [
        'Five and Sixty Tenths',
        'Five and Six Hundredths',
        'Six and Five Tenths',
        'Five and Six Tenths', // Correct answer
      ]
    },
    {
      'number': 91.82,
      'description': 'Ninety One and Eighty Two Hundredths',
      'options': [
        'Ninety One and Eighty Two Thousandths',
        'Ninety and Eighty Two Hundredths',
        'Ninety One and Eight Hundredths',
        'Ninety One and Eighty Two Hundredths', // Correct answer
      ]
    },
    {
      'number': 123.004,
      'description': 'One Hundred and Twenty Three and Four Thousandths',
      'options': [
        'One Hundred Twenty Three and Four Hundredths',
        'One Hundred Twenty Three and Forty Thousandths',
        'One Hundred and Twenty Three and Four Thousandths', // Correct answer
        'One Hundred and Twenty Three and Four Hundredths',
      ]
    },
    {
      'number': 8.1,
      'description': 'Eight and One Tenth',
      'options': [
        'Eight and Ten Hundredths',
        'Eight and One Hundredth',
        'Seven and One Tenth',
        'Eight and One Tenth', // Correct answer
      ]
    },
    {
      'number': 65.38,
      'description': 'Sixty Five and Thirty Eight Hundredths',
      'options': [
        'Sixty Six and Thirty Eight Hundredths',
        'Sixty Five and Three Hundred Eight Tenths',
        'Sixty Five and Thirty Eight Thousandths',
        'Sixty Five and Thirty Eight Hundredths', // Correct answer
      ]
    },
    {
      'number': 4.007,
      'description': 'Four and Seven Thousandths',
      'options': [
        'Four and Seventy Hundredths',
        'Four and Seventy Thousandths',
        'Four and Seven Tenths',
        'Four and Seven Thousandths', // Correct answer
      ]
    },
  ];

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

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
    IconButton(
  onPressed: _navigateToHome,
  icon: const Icon(Icons.home),
);

  }

  int currentQuestionIndex = 0;
  int score = 0;
  String selectedAnswer = '';
  // modified and add output sound
    void checkAnswer(String answer) async {
  setState(() {
    selectedAnswer = answer;
  });

  bool isCorrect = (answer == questions[currentQuestionIndex]['description']);

  if (isCorrect) {
    score++;
    await _speak("Correct. ${questions[currentQuestionIndex]['description']}");
    showCustomAnimatedDialog(
      context,
      'Correct Answer!',
      isSuccess: true,
    );
  } else {
    await _speak("Incorrect. This is ${questions[currentQuestionIndex]['description']}");
    showCustomAnimatedDialog(
      context,
      'Incorrect. Try Again!',
      isSuccess: false,
    );
  }

  await Future.delayed(const Duration(seconds: 4)); // wait after speaking

  if (isCorrect) {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = '';
      } else {
        // game over
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Game Over'),
              content: Text('Your score: $score/${questions.length}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {
                      score = 0;
                      currentQuestionIndex = 0;
                      selectedAnswer = '';
                      Navigator.of(context).pop();
                    });
                  },
                  child: const Text('Restart'),
                ),
              ],
            );
          },
        );
      }
    });
  }
}


  @override
  Widget build(BuildContext context) {
    String question = questions[currentQuestionIndex]['number'].toString();
    String correctAnswer = questions[currentQuestionIndex]['description'];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose It Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToCustomPage,
        ),
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
      body: Stack(
        children: [
      Positioned.fill(
      child: Image.asset(
      screenWidth > 1200
      ?
      'assets/matchitbackground.png': 'assets/top2.png',
        fit: screenWidth>1200? BoxFit.cover: BoxFit.cover,
      ),
    ),
    Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'What is the correct description for $question?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              for (var option in questions[currentQuestionIndex]['options'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () => checkAnswer(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedAnswer.isEmpty
                        ? Colors.purple
                        : option == correctAnswer
                          ? Colors.green
                          : selectedAnswer != correctAnswer && option == selectedAnswer
                            ? Colors.red
                            : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(option),
                  ),
                ),
              if (selectedAnswer.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    selectedAnswer == correctAnswer
                        ? 'Correct!'
                        : 'Incorrect.',
                    style: TextStyle(
                      color: selectedAnswer == correctAnswer
                          ? Colors.green
                          : Colors.red,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
      ),
    );
  }
}