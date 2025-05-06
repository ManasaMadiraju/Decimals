import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DecimalPopGame extends StatefulWidget {
  const DecimalPopGame({Key? key}) : super(key: key);

  @override
  _DecimalPopGameState createState() => _DecimalPopGameState();
}

class _DecimalPopGameState extends State<DecimalPopGame>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.23, 0.67, 0.45, 0.12],
      'answer': 0.67
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.12, 0.09, 0.25, 0.19],
      'answer': 0.25
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.3, 0.31, 0.299, 0.29],
      'answer': 0.31
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.78, 0.87, 0.65, 0.54],
      'answer': 0.87
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.111, 0.11, 0.1, 0.09],
      'answer': 0.111
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.8, 0.88, 0.82, 0.81],
      'answer': 0.88
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [0.11, 0.8, 0.18, 0.81],
      'answer': 0.81
    },
    {
      'question': 'Pick the balloon with the greatest value!',
      'options': [1.5, 1.31, 1.18, 1.42],
      'answer': 1.5
    },
  ];

  int currentQuestionIndex = 0;
  String feedbackText = "";
  String mascotMessage =
      "Hi! I'm Poppy! 🎈 Let's pop the balloons with greatest value together!";
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  late List<double> shuffledOptions;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late AnimationController _mascotController;
  late Animation<double> _mascotBounce;

  final Map<String, String> originalTexts = {
    'question': 'Pick the balloon with the greatest value!',
    'title': 'Decimal Pop Game',
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
        print('Failed to fetch translations: \${response.statusCode}');
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _shuffleOptions();
    _initAnimations();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _mascotBounce = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );
  }

  void _speakMascot(String message) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.3);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.speak(message);
  }

  void _shuffleOptions() {
    final options =
        List<double>.from(questions[currentQuestionIndex]['options']);
    options.shuffle(Random());
    shuffledOptions = options;
  }

  void _initAnimations() {
    _controllers = List.generate(
        4,
        (index) => AnimationController(
              duration: const Duration(milliseconds: 250),
              lowerBound: 0.0,
              upperBound: 1.0,
              vsync: this,
            ));
    _animations = _controllers
        .map((controller) => Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();
  }

  void checkAnswer(double selected) async {
    int index = shuffledOptions.indexOf(selected);
    await _controllers[index].forward(from: 0.0);

    bool isCorrect = selected == questions[currentQuestionIndex]['answer'];
    if (isCorrect) {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } else {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }

    setState(() {
      feedbackText = isCorrect ? "✅ Correct!" : "❌ Incorrect";
      mascotMessage = isCorrect ? "Great job!" : "Try again!";
    });

    _speakMascot(mascotMessage);

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            feedbackText = "";
            mascotMessage = "Let's pop the next balloons!";
            if (currentQuestionIndex < questions.length - 1) {
              currentQuestionIndex++;
              _shuffleOptions();
              _initAnimations();
            } else {
              _showEndDialog();
            }
          });
        }
      });
    }
  }

  void _showEndDialog() async {
    String thankYouMessage =
        "Thank you for helping me pop all the balloons! You're amazing!";
    _speakMascot(thankYouMessage);
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎈 Thank You!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/poppy.png', width: 100),
              const SizedBox(height: 10),
              Text(
                thankYouMessage,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('🏠 Home'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  currentQuestionIndex = 0;
                  _shuffleOptions();
                  _initAnimations();
                  mascotMessage =
                      "Hi! I'm Poppy! 🎈 Let's pop the biggest balloons together!";
                });
                Navigator.pop(context);
              },
              child: const Text('🔁 Play Again'),
            ),
          ],
        ),
      );
    });
  }

  String getBalloonAsset(int index) {
    final balloonColors = [
      'assets/balloon_red.png',
      'assets/balloon_purple.png',
      'assets/balloon_green.png',
      'assets/balloon_yellow.png',
    ];
    return balloonColors[index % balloonColors.length];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    _mascotController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[currentQuestionIndex];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          translated
              ? translatedTexts['title'] ?? originalTexts['title']!
              : originalTexts['title']!,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: translateTexts,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/decimalpopbg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (feedbackText.isNotEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Text(
                  feedbackText,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedBuilder(
                  animation: _mascotBounce,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_mascotBounce.value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/poppy.png',
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    mascotMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    translated
                        ? translatedTexts['question'] ??
                            originalTexts['question']!
                        : originalTexts['question']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                      fontFamily: 'ComicNeue',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: shuffledOptions.asMap().entries.map((entry) {
                    int index = entry.key;
                    double option = entry.value;
                    final imagePath = getBalloonAsset(index);

                    return GestureDetector(
                      onTap: () => checkAnswer(option),
                      child: ScaleTransition(
                        scale: _animations[index],
                        child: SizedBox(
                          width: size.width * 0.18,
                          height: size.width * 0.18,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                imagePath,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                              ),
                              Align(
                                alignment: const Alignment(0, -0.6),
                                child: Text(
                                  option.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'ComicNeue',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
