import 'package:decimals/selection_pages/GameSelectionDialog.dart';
import 'package:decimals/screens/games/chef_game/data/chef_game_data.dart';
import 'package:decimals/screens/games/chef_game/models/recipe.dart';
import 'package:decimals/screens/games/chef_game/painters/chef_game_painters.dart';
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

  List<Recipe> get recipes => chefGameRecipes;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _ingredientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ingredientScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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
    int index = baseOptions.indexOf(baseOption);
    if (index == -1) {
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
      _ingredientAnimationController.forward().then((_) {
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
    final String recipeName = recipes[currentRecipeIndex].name;
    final String message = "Amazing! You completed the $recipeName recipe!";
    _speak(message);
    final RecipeCompletionData? completionData = recipeCompletionData[recipeName];
    if (completionData != null) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) _speak(completionData.message);
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFFFFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Recipe Complete!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4E342E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildBowl(),
                const SizedBox(height: 20),
                if (completionData != null) ...[
                  Divider(height: 28, color: Colors.brown.shade200, thickness: 1),
                  Text(
                    completionData.message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey.shade100,
                            Colors.grey.shade200,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildCompletionVisual(completionData.visualType),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200, width: 1),
                  ),
                  child: Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.home_rounded, size: 20),
                label: const Text('Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
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
      case 'chickpeas':
        return const Color(0xFFD2B48C);
      case 'tahini':
        return const Color(0xFFC4A574);
      case 'lemon juice':
        return const Color(0xFFFFF8DC);
      case 'olive oil':
        return const Color(0xFFB8860B);
      case 'garlic':
        return const Color(0xFFF5F5DC);
      case 'salt':
        return Colors.white;
      case 'cumin':
        return Colors.brown.shade700;
      case 'banana':
        return const Color(0xFFFFE135);
      case 'yogurt':
        return Colors.white;
      case 'honey':
        return const Color(0xFFE6A336);
      case 'berries':
        return const Color(0xFF4A0E4E);
      case 'orange juice':
        return const Color(0xFFFFA500);
      default:
        return Colors.grey;
    }
  }

  Color _getBlendedMixtureColor() {
    if (_addedIngredients.isEmpty) return Colors.transparent;
    Color blended = _getIngredientColor(_addedIngredients.first);
    for (int i = 1; i < _addedIngredients.length; i++) {
      blended = Color.lerp(
        blended,
        _getIngredientColor(_addedIngredients[i]),
        0.3,
      )!;
    }
    return blended;
  }

  Widget _buildPanIllustration() {
    return SizedBox(
      width: 160,
      height: 100,
      child: CustomPaint(
        painter: PanPainter(),
      ),
    );
  }

  Widget _buildOvenIllustration(String variant) {
    return SizedBox(
      width: 170,
      height: 120,
      child: CustomPaint(
        painter: OvenPainter(variant: variant),
      ),
    );
  }

  Widget _buildHummusCupIllustration() {
    return SizedBox(
      width: 120,
      height: 100,
      child: CustomPaint(
        painter: HummusCupPainter(),
      ),
    );
  }

  Widget _buildSmoothieGlassIllustration() {
    return SizedBox(
      width: 100,
      height: 120,
      child: CustomPaint(
        painter: SmoothieGlassPainter(),
      ),
    );
  }

  Widget _buildCompletionVisual(String visualType) {
    switch (visualType) {
      case 'pan':
        return _buildPanIllustration();
      case 'oven_cookies':
        return _buildOvenIllustration('cookies');
      case 'oven_cake':
        return _buildOvenIllustration('cake');
      case 'cup_hummus':
        return _buildHummusCupIllustration();
      case 'glass_smoothie':
        return _buildSmoothieGlassIllustration();
      default:
        return _buildPanIllustration();
    }
  }

  Widget _buildBowl() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
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
              Positioned(
                bottom: 5,
                left: 10,
                right: 10,
                child: CustomPaint(
                  size: const Size(200, 180),
                  painter: BowlPainter(),
                ),
              ),
              if (_addedIngredients.isNotEmpty)
                Positioned(
                  bottom: 5,
                  left: 10,
                  right: 10,
                  child: AnimatedBuilder(
                    animation: _ingredientScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _ingredientScaleAnimation.value,
                        alignment: Alignment.bottomCenter,
                        child: CustomPaint(
                          size: const Size(200, 180),
                          painter: BowlContentsPainter(
                            fillHeight: (_addedIngredients.length * 25.0).clamp(0.0, 176.0),
                            fillColor: _getBlendedMixtureColor(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
        ),
        if (_addedIngredients.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: _addedIngredients.map((ing) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.brown.shade300.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ing,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )).toList(),
          ),
        ],
      ],
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
