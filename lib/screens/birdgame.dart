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
  Map<String, GlobalKey> fishKeys = {};
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
      'description': '6 Tenths and 3 Hundredths',
      'options': [
        '0.603',
        '0.63',
        '6.03',
        '0.063',
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => GameSelectionDialog()),
    );
  }

  // Method to handle home button press
  void _navigateToHome() {
    // Navigate to home screen
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void initState() {
    super.initState();
    fishKeys = {};
  }

  void checkAnswer(String answer) async {
    if (!fishKeys.containsKey(answer)) {
      fishKeys[answer] = GlobalKey();
    }
    final key = fishKeys[answer];
    if (key != null) {
      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final Offset position = renderBox.localToGlobal(Offset.zero);
        if (!mounted) return;
        setState(() {
          selectedAnswer = answer;
          correctAnswer = questions[currentQuestionIndex]['number'].toString();
          if (answer == correctAnswer) {
            feedback = "Correct!";
            _playSound('sounds/success.mp3');
            feedbackColor = Colors.green;
            showBubble = true;
            birdMoves = true;
            birdTop = position.dy - 50;
            birdLeft = position.dx;
            score++;

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
            Future.delayed(const Duration(seconds: 2), () {
              if (!mounted) return;
              setState(() {
                showBubble = false;
              });
            });
          }
        });
      }
    }
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
                  'assets/finalbackground.jpg',
                  width: width,
                  height: screenHeight * 0.9,
                  fit: BoxFit.fitWidth,
                );
              },
            ),
          ),

          Positioned(
            top: screenWidth < 500 ? screenHeight * 0.17 : screenHeight * 0.1,
            left: screenWidth * 0.06,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Help me choose the right fish to eat! $question?',
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
              'assets/bird.png',
              width: screenWidth * 0.3,
              height: screenHeight * 0.2,
            ),
          ),

          // Speech Bubble
          if (showBubble)
            Positioned(
              top: screenWidth < 500
                  ? (screenHeight * 0.4) - 40
                  : (screenHeight * 0.3) - 50,
              left: screenWidth * 0.5,
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
    return GestureDetector(
      onTap: () => checkAnswer(value),
      child: Container(
        key: fishKeys.putIfAbsent(value, () => GlobalKey()),
        width: screenWidth > 1200 ? screenWidth * 0.07 : screenWidth * 0.2,
        height: screenHeight * 0.25,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/orangefish.png'),
            fit: screenWidth > 1200 ? BoxFit.contain : BoxFit.fitWidth,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
