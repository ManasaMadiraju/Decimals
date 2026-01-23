import 'package:decimals/selection_pages/GameSelectionDialog.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChefGameScreen extends StatefulWidget {
  const ChefGameScreen({super.key});

  @override
  _ChefGameScreenState createState() => _ChefGameScreenState();
}

class Recipe {
  final String name;
  final String description;
  final List<CookingStep> steps;

  Recipe({
    required this.name,
    required this.description,
    required this.steps,
  });
}

class CookingStep {
  final String type;
  final String instruction;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String ingredient;
  final double measurement;

  CookingStep({
    required this.type,
    required this.instruction,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.ingredient,
    required this.measurement,
  });
}

class _ChefGameScreenState extends State<ChefGameScreen> with TickerProviderStateMixin {
  late SharedPreferences _preferences;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  int score = 0;
  int bestScore = 0;
  int currentRecipeIndex = 0;
  int currentStepIndex = 0;
  String selectedAnswer = '';
  String feedbackText = '';
  bool _showRecipeSelection = true;
  late AnimationController _ingredientAnimationController;
  late Animation<double> _ingredientScaleAnimation;
  List<String> _addedIngredients = [];

  final Map<String, String> originalTexts = {
    'heading': 'Let\'s cook with decimals!',
    'instruction': 'Follow the recipe steps',
  };
  Map<String, String> translatedTexts = {};
  bool translated = false;

  final List<Recipe> recipes = [
    // Recipe 1: Pancakes (7 steps)
    Recipe(
      name: "Pancakes",
      description: "Let's make delicious pancakes!",
      steps: [
        CookingStep(
          type: 'reading',
          instruction: "First, we need flour",
          question: "What does 0.5 cup mean?",
          options: ["Half a cup", "Five cups", "One cup", "Two cups"],
          correctAnswer: "Half a cup",
          ingredient: "Flour",
          measurement: 0.5,
        ),
        CookingStep(
          type: 'comparison',
          instruction: "Now we need milk",
          question: "Which is more: 0.7 cup or 0.65 cup?",
          options: ["0.7 cup", "0.65 cup", "They are equal", "I don't know"],
          correctAnswer: "0.7 cup",
          ingredient: "Milk",
          measurement: 0.7,
        ),
        CookingStep(
          type: 'place_value',
          instruction: "Add some sugar",
          question: "What is the tenths place in 0.25 cup?",
          options: ["2", "5", "0", "25"],
          correctAnswer: "2",
          ingredient: "Sugar",
          measurement: 0.25,
        ),
        CookingStep(
          type: 'fraction_conversion',
          instruction: "Add eggs",
          question: "Convert 1/4 cup to a decimal",
          options: ["0.25 cup", "0.4 cup", "0.5 cup", "1.4 cups"],
          correctAnswer: "0.25 cup",
          ingredient: "Eggs",
          measurement: 0.25,
        ),
        CookingStep(
          type: 'rounding',
          instruction: "Add oil",
          question: "Round 0.33 cup to the nearest tenth",
          options: ["0.3 cup", "0.4 cup", "0.33 cup", "0.2 cup"],
          correctAnswer: "0.3 cup",
          ingredient: "Oil",
          measurement: 0.33,
        ),
        CookingStep(
          type: 'comparison',
          instruction: "Add baking powder",
          question: "Which is more: 0.15 tsp or 0.2 tsp?",
          options: ["0.15 tsp", "0.2 tsp", "They are equal", "I don't know"],
          correctAnswer: "0.2 tsp",
          ingredient: "Baking Powder",
          measurement: 0.2,
        ),
        CookingStep(
          type: 'reading',
          instruction: "Add salt",
          question: "What does 0.1 tsp mean?",
          options: ["One tenth teaspoon", "One teaspoon", "Ten teaspoons", "One hundredth teaspoon"],
          correctAnswer: "One tenth teaspoon",
          ingredient: "Salt",
          measurement: 0.1,
        ),
      ],
    ),

    // Recipe 2: Chocolate Cake (8 steps)
    Recipe(
      name: "Chocolate Cake",
      description: "Let's bake a chocolate cake!",
      steps: [
        CookingStep(
          type: 'fraction_conversion',
          instruction: "First, measure the flour",
          question: "Convert 1/2 cup to a decimal",
          options: ["0.5 cup", "0.2 cup", "0.25 cup", "2.0 cups"],
          correctAnswer: "0.5 cup",
          ingredient: "Flour",
          measurement: 0.5,
        ),
        CookingStep(
          type: 'reading',
          instruction: "Add cocoa powder",
          question: "What does 0.75 cup mean?",
          options: ["Three quarters cup", "Seven cups", "Seventy five cups", "Half a cup"],
          correctAnswer: "Three quarters cup",
          ingredient: "Cocoa Powder",
          measurement: 0.75,
        ),
        CookingStep(
          type: 'rounding',
          instruction: "Measure the sugar",
          question: "Round 0.47 cup to the nearest tenth",
          options: ["0.5 cup", "0.4 cup", "0.47 cup", "0.6 cup"],
          correctAnswer: "0.5 cup",
          ingredient: "Sugar",
          measurement: 0.47,
        ),
        CookingStep(
          type: 'comparison',
          instruction: "Add butter",
          question: "Which is more: 0.8 cup or 0.75 cup?",
          options: ["0.8 cup", "0.75 cup", "They are equal", "I don't know"],
          correctAnswer: "0.8 cup",
          ingredient: "Butter",
          measurement: 0.8,
        ),
        CookingStep(
          type: 'place_value',
          instruction: "Add milk",
          question: "What is the hundredths place in 0.5 cup?",
          options: ["5", "0", "50", "0.5"],
          correctAnswer: "0",
          ingredient: "Milk",
          measurement: 0.5,
        ),
        CookingStep(
          type: 'fraction_conversion',
          instruction: "Add eggs",
          question: "Convert 1/3 cup to a decimal",
          options: ["0.33 cup", "0.3 cup", "0.4 cup", "1.3 cups"],
          correctAnswer: "0.33 cup",
          ingredient: "Eggs",
          measurement: 0.33,
        ),
        CookingStep(
          type: 'rounding',
          instruction: "Add vanilla extract",
          question: "Round 0.67 tsp to the nearest tenth",
          options: ["0.7 tsp", "0.6 tsp", "0.67 tsp", "0.8 tsp"],
          correctAnswer: "0.7 tsp",
          ingredient: "Vanilla Extract",
          measurement: 0.67,
        ),
        CookingStep(
          type: 'comparison',
          instruction: "Add baking soda",
          question: "Which is more: 0.25 tsp or 0.3 tsp?",
          options: ["0.25 tsp", "0.3 tsp", "They are equal", "I don't know"],
          correctAnswer: "0.3 tsp",
          ingredient: "Baking Soda",
          measurement: 0.3,
        ),
      ],
    ),

    // Recipe 3: Cookies (7 steps)
    Recipe(
      name: "Cookies",
      description: "Let's make chocolate chip cookies!",
      steps: [
        CookingStep(
          type: 'fraction_conversion',
          instruction: "Measure the flour",
          question: "Convert 1/4 cup to a decimal",
          options: ["0.25 cup", "0.4 cup", "0.5 cup", "1.4 cups"],
          correctAnswer: "0.25 cup",
          ingredient: "Flour",
          measurement: 0.25,
        ),
        CookingStep(
          type: 'place_value',
          instruction: "Add sugar",
          question: "What is the hundredths place in 0.75 cup?",
          options: ["7", "5", "0", "75"],
          correctAnswer: "5",
          ingredient: "Sugar",
          measurement: 0.75,
        ),
        CookingStep(
          type: 'rounding',
          instruction: "Add butter",
          question: "Round 0.33 cup to the nearest tenth",
          options: ["0.3 cup", "0.4 cup", "0.33 cup", "0.2 cup"],
          correctAnswer: "0.3 cup",
          ingredient: "Butter",
          measurement: 0.33,
        ),
        CookingStep(
          type: 'reading',
          instruction: "Add chocolate chips",
          question: "What does 0.5 cup mean?",
          options: ["Half a cup", "Five cups", "One cup", "Two cups"],
          correctAnswer: "Half a cup",
          ingredient: "Chocolate Chips",
          measurement: 0.5,
        ),
        CookingStep(
          type: 'comparison',
          instruction: "Add baking soda",
          question: "Which is more: 0.25 tsp or 0.2 tsp?",
          options: ["0.25 tsp", "0.2 tsp", "They are equal", "I don't know"],
          correctAnswer: "0.25 tsp",
          ingredient: "Baking Soda",
          measurement: 0.25,
        ),
        CookingStep(
          type: 'fraction_conversion',
          instruction: "Add salt",
          question: "Convert 1/2 tsp to a decimal",
          options: ["0.5 tsp", "0.2 tsp", "0.25 tsp", "2.0 tsp"],
          correctAnswer: "0.5 tsp",
          ingredient: "Salt",
          measurement: 0.5,
        ),
        CookingStep(
          type: 'place_value',
          instruction: "Add vanilla extract",
          question: "What is the tenths place in 0.1 tsp?",
          options: ["1", "0", "10", "0.1"],
          correctAnswer: "1",
          ingredient: "Vanilla Extract",
          measurement: 0.1,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _ingredientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ingredientScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ingredientAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    _ingredientAnimationController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.3);
    await _flutterTts.setSpeechRate(1);
    await _flutterTts.speak(text);
  }

  String pronounceDecimal(double decimal) {
    if (decimal == decimal.toInt()) {
      return decimal.toInt().toString();
    }

    String decimalString = decimal.toString();
    List<String> parts = decimalString.split('.');
    String wholePart = parts[0];
    String fractionalPart = parts.length > 1 ? parts[1] : "";
    String pronunciation = "";

    if (wholePart == "0") {
      pronunciation += "zero";
    } else {
      pronunciation += wholePart;
    }

    if (fractionalPart.isNotEmpty) {
      int numDigits = fractionalPart.length;
      String placeValue = "";

      switch (numDigits) {
        case 1:
          placeValue = "tenths";
          break;
        case 2:
          placeValue = "hundredths";
          break;
        case 3:
          placeValue = "thousandths";
          break;
        default:
          return "$wholePart point ${fractionalPart.split('').join(' ')}";
      }

      pronunciation += " and ${int.parse(fractionalPart)} $placeValue";
    }

    return pronunciation;
  }

  Future<void> _speakRecipeStep(CookingStep step) async {
    String scaledQuestion = _scaleAllDecimalsInText(step.question);
    String instruction = step.instruction + ". " + scaledQuestion;
    String options = "Your options are: ";
    for (String option in step.options) {
      if (option.contains('.') && option.split('.').length == 2) {
        try {
          double? value = double.tryParse(option.split(' ')[0]);
          if (value != null) {
            double scaledValue = _getScaledMeasurement(value);
            String unit = option.contains('cup') ? 'cup' : (option.contains('tsp') ? 'tsp' : '');
            options += "${pronounceDecimal(scaledValue)} $unit, ";
          } else {
            options += "$option, ";
          }
        } catch (e) {
          options += "$option, ";
        }
      } else {
        options += "$option, ";
      }
    }
    await _speak(instruction + ". " + options);
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  double _getScaledMeasurement(double baseMeasurement) {
    return baseMeasurement; // Always return base value for 1 person
  }

  String _formatMeasurement(double measurement) {
    if (measurement == measurement.toInt()) {
      return measurement.toInt().toString();
    }
    return measurement.toStringAsFixed(measurement < 1 ? 2 : 1);
  }

  String _scaleAllDecimalsInText(String text) {
    return text; // No scaling needed for 1 person
  }

  void _speakCurrentStep() {
    _flutterTts.stop();
    if (currentRecipeIndex < recipes.length &&
        currentStepIndex < recipes[currentRecipeIndex].steps.length) {
      CookingStep step = recipes[currentRecipeIndex].steps[currentStepIndex];
      _speakRecipeStep(step);
    }
  }

  void _selectRecipe(int recipeIndex) {
    setState(() {
      currentRecipeIndex = recipeIndex;
      currentStepIndex = 0;
      _showRecipeSelection = false;
      _addedIngredients = [];
    });
    String intro = "Let's make ${recipes[recipeIndex].name}! ${recipes[recipeIndex].description}";
    _speak(intro);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _speakCurrentStep();
      }
    });
  }

  Future<void> _loadBestScore() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      bestScore = _preferences.getInt('chefBestScore') ?? 0;
    });
  }

  Future<void> _saveBestScore(int newBest) async {
    if (newBest > bestScore) {
      setState(() {
        bestScore = newBest;
      });
      await _preferences.setInt('chefBestScore', newBest);
    }
  }

  void _navigateToCustomPage() {
    _saveBestScore(score);
    Navigator.of(context).pop(
      MaterialPageRoute(builder: (context) => GameSelectionDialog()),
    );
  }

  void _navigateToHome() {
    _saveBestScore(score);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

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
        translated = false;
      });
    }
  }

  void _nextStep() {
    setState(() {
      selectedAnswer = '';
      feedbackText = '';
      if (currentStepIndex < recipes[currentRecipeIndex].steps.length - 1) {
        currentStepIndex++;
        _speakCurrentStep();
      } else {
        _showRecipeCompleteDialog();
      }
    });
  }

  String _getScaledOption(String baseOption, List<String> baseOptions) {
    // Find the index to preserve order
    int index = baseOptions.indexOf(baseOption);
    if (index == -1) {
      // If not found, try to scale directly
      if (baseOption.contains('.') && baseOption.split('.').length == 2) {
        try {
          double? value = double.tryParse(baseOption.split(' ')[0]);
          if (value != null) {
            double scaledValue = _getScaledMeasurement(value);
            String unit = baseOption.contains('cup') 
                ? 'cup' 
                : (baseOption.contains('tsp') ? 'tsp' : '');
            return "${_formatMeasurement(scaledValue)} $unit";
          }
        } catch (e) {
          // Keep original if parsing fails
        }
      }
      return baseOption;
    }
    
    // Scale the option at this index
    String option = baseOptions[index];
    if (option.contains('.') && option.split('.').length == 2) {
      try {
        double? value = double.tryParse(option.split(' ')[0]);
        if (value != null) {
          double scaledValue = _getScaledMeasurement(value);
          String unit = option.contains('cup') 
              ? 'cup' 
              : (option.contains('tsp') ? 'tsp' : '');
          return "${_formatMeasurement(scaledValue)} $unit";
        }
      } catch (e) {
        // Keep original if parsing fails
      }
    }
    return option;
  }

  String _scaleSingleOption(String option) {
    return option; // No scaling needed for 1 person
  }

  void checkAnswer(String scaledAnswer, String baseAnswer) async {
    final currentStep = recipes[currentRecipeIndex].steps[currentStepIndex];
    // Since we're not scaling anymore, compare directly with the base correct answer
    String correctAnswer = currentStep.correctAnswer;

    setState(() {
      selectedAnswer = scaledAnswer;
    });

    if (scaledAnswer == correctAnswer) {
      await _playSound('sounds/success.mp3');
      await _speak("Correct! Great job!");
      setState(() {
        feedbackText = "Correct!";
        score += 10;
        _saveBestScore(score);
        _addedIngredients.add(currentStep.ingredient);
      });
      _ingredientAnimationController.forward(from: 0.0).then((_) {
        _ingredientAnimationController.reverse();
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _nextStep();
        }
      });
    } else {
      await _playSound('sounds/error.mp3');
      await _speak("Try again!");
      setState(() {
        feedbackText = "Try again!";
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            feedbackText = '';
            selectedAnswer = '';
          });
        }
      });
    }
  }

  void _showRecipeCompleteDialog() {
    String message = "Amazing! You completed the ${recipes[currentRecipeIndex].name} recipe!";
    _speak(message);
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Recipe Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildBowl(),
              const SizedBox(height: 20),
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Home'),
            ),
          ],
        ),
      );
    });
  }

  void _showAllRecipesCompleteDialog() {
    String message = "Congratulations! You completed all recipes!";
    _speak(message);
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('All Recipes Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildBowl(),
              const SizedBox(height: 20),
              Text(
                'Final Score: $score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Home'),
            ),
          ],
        ),
      );
    });
  }

  Color _getIngredientColor(String ingredient) {
    switch (ingredient.toLowerCase()) {
      case 'flour':
        return const Color(0xFFF5F5DC);
      case 'milk':
        return Colors.white;
      case 'sugar':
        return Colors.white;
      case 'cocoa powder':
        return Colors.brown.shade800;
      case 'butter':
        return Colors.yellow.shade200;
      case 'chocolate chips':
        return Colors.brown.shade900;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBowl() {
    return Container(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Bowl shadow (elliptical, wider)
          Positioned(
            bottom: 0,
            child: Container(
              width: 200,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Bowl outer shape (U-shape cross-section)
          Positioned(
            bottom: 5,
            left: 10,
            right: 10,
            child: CustomPaint(
              size: const Size(200, 180),
              painter: BowlPainter(),
            ),
          ),
          // Ingredients layers (increasing width)
          if (_addedIngredients.isNotEmpty)
            ..._addedIngredients.asMap().entries.map((entry) {
              int index = entry.key;
              String ingredient = entry.value;
              Color ingredientColor = _getIngredientColor(ingredient);
              double layerHeight = 25.0;
              double bottomOffset = 25 + (index * layerHeight);
              
              // Calculate width based on bowl radius at this height
              // Bowl is wider at top (200px) and narrower at bottom (120px)
              double bowlTopWidth = 200.0;
              double bowlBottomWidth = 120.0;
              double bowlHeight = 180.0;
              double currentHeight = bottomOffset - 25; // Height from bottom
              double progress = currentHeight / bowlHeight; // 0 at bottom, 1 at top
              double layerWidth = bowlBottomWidth + (progress * (bowlTopWidth - bowlBottomWidth));
              
              return Positioned(
                bottom: bottomOffset,
                left: (220 - layerWidth) / 2, // Center the layer
                child: AnimatedBuilder(
                  animation: _ingredientScaleAnimation,
                  builder: (context, child) {
                    double scale = index == _addedIngredients.length - 1 
                        ? _ingredientScaleAnimation.value 
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: layerWidth,
                        height: layerHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              ingredientColor,
                              ingredientColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            ingredient,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          // Empty bowl message
          if (_addedIngredients.isEmpty)
            Positioned(
              bottom: 90,
              child: Text(
                "Empty Bowl",
                style: TextStyle(
                  color: Colors.brown.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipeSelectionScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Choose a Recipe"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToCustomPage,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _navigateToHome,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              screenWidth > 1200
                  ? 'assets/matchitbackground.png'
                  : 'assets/b2.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Choose a Recipe',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 30),
                      for (int i = 0; i < recipes.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _selectRecipe(i),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    recipes[i].name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    recipes[i].description,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_showRecipeSelection) {
      return _buildRecipeSelectionScreen();
    }

    if (currentRecipeIndex >= recipes.length) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("Decimal Chef!"),
        ),
        body: const Center(
          child: Text("All recipes completed!"),
        ),
      );
    }

    final currentRecipe = recipes[currentRecipeIndex];
    final currentStep = currentRecipe.steps[currentStepIndex];
    String scaledQuestion = _scaleAllDecimalsInText(currentStep.question);
    List<String> scaledOptions = currentStep.options.map((option) {
      return _scaleSingleOption(option);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: RichText(
          text: TextSpan(style: const TextStyle(fontSize: 24), children: [
            const TextSpan(text: "Decimal Chef! "),
            TextSpan(
              text: "Score: $score",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ]),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToCustomPage,
        ),
        actions: [
          Text(
            "Best Score: $bestScore",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Padding(padding: const EdgeInsets.all(5.0)),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _navigateToHome,
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
            child: Image.asset(
              screenWidth > 1200
                  ? 'assets/matchitbackground.png'
                  : 'assets/b2.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        currentRecipe.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Step ${currentStepIndex + 1} of ${currentRecipe.steps.length}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildBowl(),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              currentStep.instruction,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              scaledQuestion,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: _speakCurrentStep,
                                  icon: const Icon(Icons.volume_up),
                                  iconSize: 32,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (feedbackText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            feedbackText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: feedbackText == "Correct!" ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          for (int i = 0; i < scaledOptions.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: selectedAnswer.isEmpty
                                      ? () => checkAnswer(scaledOptions[i], currentStep.options[i])
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedAnswer.isEmpty
                                        ? Colors.orange
                                        : scaledOptions[i] == currentStep.correctAnswer
                                            ? Colors.green
                                            : selectedAnswer == scaledOptions[i]
                                                ? Colors.red
                                                : Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minimumSize: const Size(0, 60),
                                  ),
                                  child: Text(
                                    scaledOptions[i],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for U-shape bowl cross-section
class BowlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient shader
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.brown.shade300,
        Colors.brown.shade600,
      ],
    );
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final path = Path();
    // Create U-shape: wider at top, narrower at bottom
    double topWidth = size.width;
    double bottomWidth = size.width * 0.6; // 60% of top width
    double height = size.height;
    double leftStart = (size.width - topWidth) / 2;
    double rightStart = (size.width + topWidth) / 2;
    double leftBottom = (size.width - bottomWidth) / 2;
    double rightBottom = (size.width + bottomWidth) / 2;
    
    // Start at top-left
    path.moveTo(leftStart, 0);
    
    // Left side (curved inward)
    path.quadraticBezierTo(
      leftStart + (leftBottom - leftStart) * 0.5,
      height * 0.3,
      leftBottom,
      height,
    );
    
    // Bottom (flat)
    path.lineTo(rightBottom, height);
    
    // Right side (curved outward)
    path.quadraticBezierTo(
      rightBottom + (rightStart - rightBottom) * 0.5,
      height * 0.3,
      rightStart,
      0,
    );
    
    // Top rim (flat)
    path.lineTo(leftStart, 0);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Rim highlight (outer border)
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.brown.shade800
      ..strokeWidth = 3;
    canvas.drawPath(path, rimPaint);
    
    // Inner highlight for depth
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.brown.shade200.withOpacity(0.5)
      ..strokeWidth = 1;
    
    final innerPath = Path();
    double innerTopWidth = topWidth * 0.95;
    double innerBottomWidth = bottomWidth * 0.95;
    double innerLeftStart = (size.width - innerTopWidth) / 2;
    double innerRightStart = (size.width + innerTopWidth) / 2;
    double innerLeftBottom = (size.width - innerBottomWidth) / 2;
    double innerRightBottom = (size.width + innerBottomWidth) / 2;
    
    innerPath.moveTo(innerLeftStart, 2);
    innerPath.quadraticBezierTo(
      innerLeftStart + (innerLeftBottom - innerLeftStart) * 0.5,
      height * 0.3,
      innerLeftBottom,
      height - 2,
    );
    innerPath.lineTo(innerRightBottom, height - 2);
    innerPath.quadraticBezierTo(
      innerRightBottom + (innerRightStart - innerRightBottom) * 0.5,
      height * 0.3,
      innerRightStart,
      2,
    );
    innerPath.lineTo(innerLeftStart, 2);
    canvas.drawPath(innerPath, innerPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
