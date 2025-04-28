import 'package:decimals/GameSelectionDialog.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:decimals/custom_dialog.dart';

class LizzieTheBirdGame extends StatefulWidget {
  const LizzieTheBirdGame({super.key});

  @override
  _LizzieTheBirdGameState createState() => _LizzieTheBirdGameState();
}

class _LizzieTheBirdGameState extends State<LizzieTheBirdGame> {
  String feedback = "";
  Color feedbackColor = Colors.black;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool showBubble = false;
  bool birdMoves = false;
  double birdTop = 400;
  double birdLeft = 400;
  int currentQuestionIndex = 0;
  int score = 0;
  String selectedAnswer = '';
  String correctAnswer = '';
  final GlobalKey _correctFishKey = GlobalKey();
  Set<String> hiddenFishes = {};
  final Map<String, String> originalTexts = {
    'heading': 'Help me choose the right fish to eat!\n',
  };
  Map<String, String> translatedTexts = {};
  bool translated = false;
  Future<void> translateTexts() async {
    if (!translated) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'texts': originalTexts.values.toList()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          translatedTexts = {
            for (int i = 0; i < originalTexts.keys.length; i++)
              originalTexts.keys.elementAt(i): data['translations'][i]
          };
          translated = true;
        });
      } else {
        print('Failed to fetch translations: ${response.statusCode}');
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false; // Mark as untranslated
      });
    }
  }

  final List<Map<String, dynamic>> questions = [
    {
      'number': 0.25,
      'description': '25 Hundredths',
      'options': ['0.025', '0.25', '2.5', '0.0025'],
    },
    {
      'number': 0.007,
      'description': '7 Thousandths',
      'options': ['0.07', '0.007', '0.7', '0.0007'],
    },
    {
      'number': 3.14,
      'description': '3 and 14 Hundredths',
      'options': ['3.14', '3.014', '31.4', '0.314'],
    },
    {
      'number': 0.63,
      'description': 'Sixty three hundredths',
      'options': ['0.603', '0.63', '6.03', '0.063'],
    },
    {
      'number': 48,
      'description': 'Forty Eight',
      'options': ['0.48', '4.8', '48', '480'],
    },
    {
      'number': 0.2,
      'description': '2 Tenths',
      'options': ['0.2', '0.02', '0.002', '2'],
    },
    {
      'number': 0.123,
      'description': 'One hundred twenty-three thousandths',
      'options': ['0.12', '123', '0.123', '0.0123'],
    },
    {
      'number': 0.009,
      'description': 'Nine thousandths',
      'options': ['0.09', '0.009', '0.0009', '0.9'],
    },
  ];

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _navigateToCustomPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GameSelectionDialog()),
    );
  }

  void _navigateToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void checkAnswer(String answer) {
    final String correctValue = questions[currentQuestionIndex]['number'].toString();

    setState(() {
      selectedAnswer = answer;

      if (answer == correctValue) {
        _playSound('sounds/success.mp3');
        showCustomAnimatedDialog(context, "Correct!", isSuccess: true);
        showBubble = true;
        feedbackColor = Colors.green;
        score++;

        final renderBox = _correctFishKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final Offset position = renderBox.localToGlobal(Offset.zero);
          birdTop = position.dy - 50;
          birdLeft = position.dx;
          birdMoves = true;
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            birdMoves = false;
          });
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          setState(() {
            showBubble = false;
            if (currentQuestionIndex < questions.length - 1) {
              currentQuestionIndex++;
            }
          });
        });
      } else {
        _playSound('sounds/error.mp3');
        showCustomAnimatedDialog(context, "Try Again!", isSuccess: false);
        showBubble = true;
        feedbackColor = Colors.red;

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() => showBubble = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String question = questions[currentQuestionIndex]['description'];

    birdLeft = screenWidth < 1200 ? birdLeft - 60 : birdLeft - 160;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Play: Lizzie the Bird'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToCustomPage,
        ),
        backgroundColor: Colors.green,
        actions: [
          Text(
            "Score: $score",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _navigateToHome,
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: translateTexts,
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: translateTexts,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Image.asset(
                  screenWidth > 1200 ? 'assets/backdrop.png' : 'assets/backdrop2.jpeg',
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.9,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.035,
            right: 0,
            child: Column(
              children: [
                Container(
                  // padding: const EdgeInsets.all(10),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(15),
                  // ),
                  child: Text(
                    translated
                        ? '${translatedTexts['heading'] ?? originalTexts['heading']} $question?'
                        : '${originalTexts['heading']} $question?',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: feedbackColor),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            top: birdMoves ? birdTop : screenHeight * 0.2,
            left: birdMoves ? birdLeft : screenWidth * 0.35,
            child: Image.asset(
              'assets/birdnew.png',
              width: screenWidth * 0.3,
              height: screenHeight * 0.2,
            ),
          ),
          if (showBubble)
            Positioned(
              top: screenHeight * 0.3,
              left: screenWidth * 0.55,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  feedback,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: feedbackColor,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: screenWidth < 500 ? screenWidth * 0.2 : screenWidth * 0.05,
            left: screenWidth * 0.03,
            right: 0,
            child: Wrap(
              spacing: screenWidth * 0.03,
              runSpacing: screenHeight * 0.01,
              alignment: WrapAlignment.center,
              children: [
                for (var option in questions[currentQuestionIndex]['options'])
                  buildFishButton(option, screenWidth, screenHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFishButton(String value, double screenWidth, double screenHeight) {
    final String correctValue = questions[currentQuestionIndex]['number'].toString();
    final bool isCorrect = value == correctValue;
    return GestureDetector(
      onTap: () => checkAnswer(value),
      child: Container(
        key: isCorrect ? _correctFishKey : null,
        width: screenWidth > 1200 ? screenWidth * 0.15 : screenWidth * 0.35,
        height: screenWidth > 1200 ? screenHeight * 0.2 : screenWidth * 0.3,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fishnew.png'),
            fit: screenWidth > 1200 ? BoxFit.fitWidth : BoxFit.fitHeight,
          ),
        ),
        alignment: const Alignment(0.2, 0),
        child: Text(
          value,
          style: TextStyle(
            fontSize: screenWidth > 1200 ? 20 : 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
