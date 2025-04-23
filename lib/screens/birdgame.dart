import 'package:decimals/GameSelectionDialog.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
  double birdTop = 400; // Initial position
  double birdLeft = 400; // Initial position // Initial bird position
  int currentQuestionIndex = 0;
  int score = 0;
  String selectedAnswer = '';
  String correctAnswer = '';
  double birdTop2 = 200;
  double birdLeft2 = 450;
  final GlobalKey _correctFishKey = GlobalKey();
  Set<String> hiddenFishes = {};
  final List<Map<String, dynamic>> questions = [
    {
      'number': 0.25,
      'description': '25 Hundredths',
      'options': [
        '0.025',
        '0.25',
        '2.5',
        '0.0025',
      ]
    },
    {
      'number': 0.007,
      'description': '7 Thousandths',
      'options': [
        '0.07',
        '0.007',
        '0.7',
        '0.0007',
      ]
    },
    {
      'number': 3.14,
      'description': '3 and 14 Hundredths',
      'options': [
        '3.14',
        '3.014',
        '31.4',
        '0.314',
      ]
    },
    {
      'number': 0.63,
      'description': 'Sixty three hundredth',
      'options': [
        '0.603',
        '0.63',
        '6.03',
        '0.063',
      ]
    },
    {
      'number': 48,
      'description': 'Forty Eight',
      'options': [
        '0.48',
        '4.8',
        '48',
        '480',
      ]
    },
    {
      'number': 0.2,
      'description': '2 Tenths',
      'options': [
        '0.2',
        '0.02',
        '0.002',
        '2',
      ]
    },
    {
      'number': 0.123,
      'description': 'one hundred twenty-three thousandths',
      'options': [
        '0.12',
        '123',
        '0.123',
        '0.0123',
      ]
    },
    {
      'number': 0.009,
      'description': 'Nine thousandths',
      'options': [
        '0.09',
        '0.009',
        '0.0009',
        '0.9',
      ]
    },
  ];

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print("Error playing sound: $e");
    }
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
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  // void initState() {
  //   super.initState();
  //   fishKeys = {};
  // }
  // void checkAnswer(String answer) async {
  //   if (!fishKeys.containsKey(answer)) {
  //     fishKeys[answer] = GlobalKey();
  //   }
  //   final key = fishKeys[answer];
  //   if (key != null) {
  //     final RenderBox? renderBox =
  //     key.currentContext?.findRenderObject() as RenderBox?;
  //     if (renderBox != null) {
  //       final Offset position = renderBox.localToGlobal(Offset.zero);
  //       if (!mounted) return;
  //       setState(() {
  //         selectedAnswer = answer;
  //         correctAnswer = questions[currentQuestionIndex]['number'].toString();
  //         if (answer == correctAnswer) {
  //           feedback = "Correct!";
  //           _playSound('sounds/success.mp3');
  //           feedbackColor = Colors.green;
  //           showBubble = true;
  //           birdMoves = true;
  //           birdTop = position.dy - 50;
  //           birdLeft = position.dx;
  //           score++;
  //
  //           Future.delayed(const Duration(seconds: 2), () {
  //             if (!mounted) return;
  //             setState(() {
  //               hiddenFishes.add(answer);
  //               birdMoves = false;
  //             });
  //           });
  //
  //           Future.delayed(const Duration(seconds: 3), () {
  //             if (!mounted) return;
  //             setState(() {
  //               showBubble = false;
  //               if (currentQuestionIndex < questions.length - 1) {
  //                 hiddenFishes.clear();
  //                 currentQuestionIndex++;
  //               }
  //             });
  //           });
  //         } else {
  //           feedback = "Try Again!";
  //           feedbackColor = Colors.red;
  //           _playSound('sounds/error.mp3');
  //           showBubble = true;
  //           Future.delayed(const Duration(seconds: 2), () {
  //             if (!mounted) return;
  //             setState(() {
  //               showBubble = false;
  //             });
  //           });
  //         }
  //       });
  //     }
  //   }
  // }
  void checkAnswer(String answer) {
    final String correctValue =
        questions[currentQuestionIndex]['number'].toString();

    setState(() {
      selectedAnswer = answer;

      if (answer == correctValue) {
        feedback = "Correct!";
        feedbackColor = Colors.green;
        _playSound('sounds/success.mp3');
        showBubble = true;
        score++;

        // get position of the correct fish
        final renderBox =
            _correctFishKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final Offset position = renderBox.localToGlobal(Offset.zero);
          birdTop = position.dy - 50;
          birdLeft = position.dx;
          birdMoves = true;
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            hiddenFishes.add(answer);
            birdMoves = false;
          });
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          setState(() {
            showBubble = false;
            if (currentQuestionIndex < questions.length - 1) {
              hiddenFishes.clear();
              currentQuestionIndex++;
            }
          });
        });
      } else {
        feedback = "Try Again!";
        feedbackColor = Colors.red;
        _playSound('sounds/error.mp3');
        showBubble = true;
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
    String correctAnswer = questions[currentQuestionIndex]['number'].toString();
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
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth < 1200
                    ? screenWidth
                    : screenWidth * 0.4;

                return Image.asset(
                  screenWidth > 1200
                      ? 'assets/backdrop.png'
                      : 'assets/backdrop2.jpeg',
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.9,
                  fit: BoxFit.fill,
                );
              },
            ),
          ),

          Positioned(
            top: screenWidth < 500 ? screenHeight * 0.15 : screenHeight * 0.15,
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
                    'Help me choose the right fish to eat!\n                    $question?',
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

          // Speech Bubble
          if (showBubble)
            Positioned(
              top: screenWidth < 500
                  ? (screenHeight * 0.4) - 60
                  : (screenHeight * 0.3) - 40,
              left: screenWidth < 1200 ? screenWidth * 0.6 : screenWidth * 0.55,
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
                      color: feedbackColor),
                ),
              ),
            ),

          // Fish Buttons
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
                  if (!hiddenFishes.contains(option))
                    buildFishButton(option, screenWidth, screenHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFishButton(
      String value, double screenWidth, double screenHeight) {
    final String correctValue =
        questions[currentQuestionIndex]['number'].toString();
    final bool isCorrect = value == correctValue;
    return GestureDetector(
      onTap: () => checkAnswer(value),
      child: Container(
        // only the correct fish gets the key:
        key: isCorrect ? _correctFishKey : null,
        width: screenWidth > 1200 ? screenWidth * 0.15 : screenWidth * 0.35,
        height: screenWidth > 1200 ? screenHeight * 0.2 : screenWidth * 0.3,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fishnew.png'),
            fit: screenWidth > 1200 ? BoxFit.fitWidth : BoxFit.fitHeight,
          ),
        ),
        alignment: Alignment(0.2, 0),
        child: Container(
          child: Text(
            value,
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 20 : 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
