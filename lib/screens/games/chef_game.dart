import 'dart:math';
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
  List<String> _shuffledScaledOptions = [];
  late AnimationController _entranceController;
  final List<Animation<double>> _entranceAnimations = [];
  int _pressedChoiceIndex = -1;
  late AnimationController _correctPulseController;
  late Animation<double> _correctPulseAnimation;
  late AnimationController _wrongShakeController;
  int _wrongShakeIndex = -1;
  bool _allCompleteDialogShown = false;

  static const String _decimalChef = 'Decimal Chef!';
  static const String _score = 'Score';
  static const String _bestScore = 'Best Score';
  static const String _listen = 'Listen';
  static const String _emptyBowl = 'Empty Bowl';
  static const String _step = 'Step';
  static const String _of = 'of';

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
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    for (int i = 0; i < 4; i++) {
      _entranceAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(i * 0.2, 0.2 + i * 0.2, curve: Curves.easeOut),
          ),
        ),
      );
    }
    _correctPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _correctPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _correctPulseController,
        curve: Curves.elasticOut,
      ),
    );
    _wrongShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    _ingredientAnimationController.dispose();
    _entranceController.dispose();
    _correctPulseController.dispose();
    _wrongShakeController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage(translated ? "es-ES" : "en-US");
    await _flutterTts.setPitch(1);
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
    String instruction;
    String options;
    if (translated && translatedTexts.isNotEmpty) {
      instruction = '${translatedTexts['current_instruction'] ?? step.instruction}. ${translatedTexts['current_question'] ?? _scaleAllDecimalsInText(step.question)}';
      final prompt = translatedTexts['options_prompt'] ?? _optionsPrompt;
      options = prompt +
          [0, 1, 2, 3].map((i) => translatedTexts['option_$i'] ?? '').where((s) => s.isNotEmpty).join(', ');
    } else {
      String scaledQuestion = _scaleAllDecimalsInText(step.question);
      instruction = step.instruction + ". " + scaledQuestion;
      options = _optionsPrompt;
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

  List<String> _buildShuffledScaledOptionsForCurrentStep() {
    if (currentRecipeIndex >= recipes.length) return [];
    final step = recipes[currentRecipeIndex].steps[currentStepIndex];
    final scaled = step.options.map((o) => _scaleSingleOption(o)).toList();
    scaled.shuffle(Random());
    return scaled;
  }

  void _selectRecipe(int recipeIndex) {
    setState(() {
      currentRecipeIndex = recipeIndex;
      currentStepIndex = 0;
      _showRecipeSelection = false;
      _addedIngredients = [];
      _shuffledScaledOptions = _buildShuffledScaledOptionsForCurrentStep();
      _entranceController.reset();
      _entranceController.forward();
    });
    String intro = "Let's make ${recipes[recipeIndex].name}!";
    _speak(intro);
    if (translated) {
      _refetchTranslationsForCurrentStep();
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _speakCurrentStep();
      }
    });
  }

  /// Re-fetches translations for the current step and updates [translatedTexts]. Keeps [translated] true.
  Future<void> _refetchTranslationsForCurrentStep() async {
    final keys = <String>[];
    final values = <String>[];
    _buildTranslationPayload(keys, values);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'texts': values}),
      );
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final translations = List<String>.from(data['translations'] as List);
        if (translations.length == keys.length) {
          setState(() {
            translatedTexts = {for (int i = 0; i < keys.length; i++) keys[i]: translations[i]};
          });
        }
      }
    } catch (_) {
      // Keep existing translatedTexts; new step may show mixed until next manual translate
    }
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

  static const String _optionsPrompt = 'Your options are: ';

  /// Builds ordered [keys] and [values] for the current game screen for translation.
  void _buildTranslationPayload(List<String> keys, List<String> values) {
    keys.addAll([
      'decimal_chef', 'score', 'best_score', 'listen', 'empty_bowl', 'step', 'of', 'heading',
      'options_prompt',
      'recipe_name', 'current_instruction', 'current_question',
      'option_0', 'option_1', 'option_2', 'option_3',
    ]);
    final recipe = recipes[currentRecipeIndex];
    final step = recipe.steps[currentStepIndex];
    final scaledQuestion = _scaleAllDecimalsInText(step.question);
    final displayOpts = _shuffledScaledOptions.length == step.options.length
        ? _shuffledScaledOptions
        : step.options.map((o) => _scaleSingleOption(o)).toList();
    values.addAll([
      _decimalChef, _score, _bestScore, _listen, _emptyBowl, _step, _of, originalTexts['heading']!,
      _optionsPrompt,
      recipe.name, step.instruction, scaledQuestion,
      displayOpts.length > 0 ? displayOpts[0] : '', displayOpts.length > 1 ? displayOpts[1] : '',
      displayOpts.length > 2 ? displayOpts[2] : '', displayOpts.length > 3 ? displayOpts[3] : '',
    ]);
    for (int i = 0; i < _addedIngredients.length; i++) {
      keys.add('ingredient_$i');
      values.add(_addedIngredients[i]);
    }
  }

  Future<void> translateTexts() async {
    if (!translated) {
      final keys = <String>[];
      final values = <String>[];
      _buildTranslationPayload(keys, values);
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/translate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'texts': values}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final translations = List<String>.from(data['translations'] as List);
          if (mounted && translations.length == keys.length) {
            setState(() {
              translatedTexts = {for (int i = 0; i < keys.length; i++) keys[i]: translations[i]};
              translated = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Translated to Spanish')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Translation failed: ${response.statusCode}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Translation unavailable. Start the backend server (see README).'),
            ),
          );
        }
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Switched back to English')),
        );
      }
    }
  }

  void _nextStep() {
    final didAdvance = currentStepIndex < recipes[currentRecipeIndex].steps.length - 1;
    setState(() {
      selectedAnswer = '';
      feedbackText = '';
      if (didAdvance) {
        currentStepIndex++;
        _shuffledScaledOptions = _buildShuffledScaledOptionsForCurrentStep();
        _entranceController.reset();
        _entranceController.forward();
        _correctPulseController.reset();
      } else {
        _showRecipeCompleteDialog();
      }
    });
    if (didAdvance) {
      if (translated) {
        // Fetch new step's translations first, then speak so we don't speak the old question.
        _refetchTranslationsForCurrentStep().then((_) {
          if (mounted) _speakCurrentStep();
        });
      } else {
        _speakCurrentStep();
      }
    }
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
      _correctPulseController.forward(from: 0).then((_) {
        _correctPulseController.reverse();
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
      final wrongIndex = _shuffledScaledOptions.indexOf(scaledAnswer);
      setState(() {
        feedbackText = "Try again!";
        _wrongShakeIndex = wrongIndex >= 0 ? wrongIndex : -1;
      });
      if (_wrongShakeIndex >= 0) {
        _wrongShakeController.forward(from: 0);
      }
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            feedbackText = '';
            selectedAnswer = '';
            _wrongShakeIndex = -1;
          });
        }
      });
    }
  }

  Future<void> _showRecipeCompleteDialog() async {
    final String recipeName = recipes[currentRecipeIndex].name;
    final String message = "Amazing! You completed the $recipeName recipe!";
    _speak(message);
    final RecipeCompletionData? completionData = recipeCompletionData[recipeName];
    if (completionData != null) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) _speak(completionData.message);
      });
    }

    String dialogTitle = 'Recipe Complete!';
    String dialogMessage = message;
    String dialogStatus = completionData?.message ?? '';
    String scoreLabel = 'Score';
    String homeLabel = 'Home';

    if (translated) {
      final toTranslate = <String>[dialogTitle, dialogMessage];
      if (completionData != null) toTranslate.add(dialogStatus);
      toTranslate.addAll([scoreLabel, homeLabel]);
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/translate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'texts': toTranslate}),
        );
        if (response.statusCode == 200 && mounted) {
          final data = jsonDecode(response.body);
          final t = List<String>.from(data['translations'] as List);
          if (t.length == toTranslate.length) {
            dialogTitle = t[0];
            dialogMessage = t[1];
            int i = 2;
            if (completionData != null) {
              dialogStatus = t[i++];
            }
            scoreLabel = t[i++];
            homeLabel = t[i];
          }
        }
      } catch (_) {}
    }

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
            Text(
              dialogTitle,
              style: const TextStyle(
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
                dialogMessage,
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
                  dialogStatus,
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
                  '$scoreLabel: $score',
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
              label: Text(homeLabel),
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
  }

  Future<void> _showAllRecipesCompleteDialog() async {
    String message = "Congratulations! You completed all recipes!";
    _speak(message);

    String dialogTitle = 'All Recipes Complete!';
    String dialogMessage = message;
    String finalScoreLabel = 'Final Score';
    String homeLabel = 'Home';

    if (translated) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/translate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'texts': [dialogTitle, dialogMessage, finalScoreLabel, homeLabel],
          }),
        );
        if (response.statusCode == 200 && mounted) {
          final data = jsonDecode(response.body);
          final t = List<String>.from(data['translations'] as List);
          if (t.length >= 4) {
            dialogTitle = t[0];
            dialogMessage = t[1];
            finalScoreLabel = t[2];
            homeLabel = t[3];
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(dialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dialogMessage,
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
                '$finalScoreLabel: $score',
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
              child: Text(homeLabel),
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
                    translated ? (translatedTexts['empty_bowl'] ?? _emptyBowl) : _emptyBowl,
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
            children: _addedIngredients.asMap().entries.map((e) {
              final label = translated ? (translatedTexts['ingredient_${e.key}'] ?? e.value) : e.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.brown.shade300.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
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

  Widget _buildChoiceWithFeedback({
    required int choiceIndex,
    required String choiceLabel,
    required List<String> displayOptions,
    required CookingStep currentStep,
    required double pulseScale,
    required double shakeOffsetX,
  }) {
    final i = choiceIndex;
    Widget child = Transform.scale(
      scale: _pressedChoiceIndex == i ? 0.96 : 1.0,
      child: GestureDetector(
        onTapDown: (_) {
          if (selectedAnswer.isEmpty) {
            setState(() => _pressedChoiceIndex = i);
          }
        },
        onTapUp: (_) => setState(() => _pressedChoiceIndex = -1),
        onTapCancel: () => setState(() => _pressedChoiceIndex = -1),
        child: _ChefChoiceButton(
          label: choiceLabel,
          isCorrect: selectedAnswer.isNotEmpty &&
              displayOptions[i] == currentStep.correctAnswer,
          isWrong: selectedAnswer == displayOptions[i] &&
              displayOptions[i] != currentStep.correctAnswer,
          isDisabled: selectedAnswer.isNotEmpty,
          onTap: selectedAnswer.isEmpty
              ? () => checkAnswer(displayOptions[i], displayOptions[i])
              : null,
        ),
      ),
    );
    if (selectedAnswer.isNotEmpty &&
        displayOptions[i] == currentStep.correctAnswer) {
      child = Transform.scale(scale: pulseScale, child: child);
    }
    if (i == _wrongShakeIndex) {
      child = Transform.translate(
        offset: Offset(shakeOffsetX, 0),
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_showRecipeSelection) {
      return _buildRecipeSelectionScreen();
    }

    if (currentRecipeIndex >= recipes.length) {
      if (!_allCompleteDialogShown) {
        _allCompleteDialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showAllRecipesCompleteDialog();
        });
      }
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
    final List<String> displayOptions = _shuffledScaledOptions.length == currentStep.options.length
        ? _shuffledScaledOptions
        : currentStep.options.map((o) => _scaleSingleOption(o)).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: RichText(
          text: TextSpan(style: const TextStyle(fontSize: 24), children: [
            TextSpan(
              text: '${translated ? (translatedTexts['decimal_chef'] ?? _decimalChef) : _decimalChef} ',
            ),
            TextSpan(
              text: '${translated ? (translatedTexts['score'] ?? _score) : _score}: $score',
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
            '${translated ? (translatedTexts['best_score'] ?? _bestScore) : _bestScore}: $bestScore',
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
                        translated
                            ? (translatedTexts['heading'] ?? originalTexts['heading']!)
                            : originalTexts['heading']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        translated ? (translatedTexts['recipe_name'] ?? currentRecipe.name) : currentRecipe.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${translated ? (translatedTexts['step'] ?? _step) : _step} ${currentStepIndex + 1} ${translated ? (translatedTexts['of'] ?? _of) : _of} ${currentRecipe.steps.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildBowl(),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber.shade50,
                              Colors.orange.shade50,
                              Colors.amber.shade100,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.orange.shade700,
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                translated ? (translatedTexts['current_instruction'] ?? currentStep.instruction) : currentStep.instruction,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              translated ? (translatedTexts['current_question'] ?? scaledQuestion) : scaledQuestion,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                                shadows: [
                                  Shadow(
                                    color: Colors.white54,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Material(
                              color: Colors.orange.shade400,
                              borderRadius: BorderRadius.circular(28),
                              elevation: 2,
                              child: InkWell(
                                onTap: _speakCurrentStep,
                                borderRadius: BorderRadius.circular(28),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.volume_up,
                                        size: 28,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        translated ? (translatedTexts['listen'] ?? _listen) : _listen,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
                      if (feedbackText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: 1,
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey(feedbackText),
                              tween: Tween(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.elasticOut,
                              builder: (context, scale, child) => Transform.scale(
                                scale: scale,
                                child: child,
                              ),
                              child: Text(
                                feedbackText,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: feedbackText == "Correct!"
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
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
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _entranceController,
                          _correctPulseController,
                          _wrongShakeController,
                        ]),
                        builder: (context, child) {
                          final pulseScale = selectedAnswer.isNotEmpty
                              ? _correctPulseAnimation.value
                              : 1.0;
                          final shakeX = _wrongShakeIndex >= 0
                              ? 6 * sin(4 * pi * _wrongShakeController.value)
                              : 0.0;
                          return Column(
                            children: [
                              for (int i = 0; i < displayOptions.length; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      24 * (1 - (i < _entranceAnimations.length
                                          ? _entranceAnimations[i].value
                                          : 1.0)),
                                    ),
                                    child: Opacity(
                                      opacity: i < _entranceAnimations.length
                                          ? _entranceAnimations[i].value
                                          : 1.0,
                                      child: _buildChoiceWithFeedback(
                                        choiceIndex: i,
                                        choiceLabel: translated
                                            ? (translatedTexts['option_$i'] ?? displayOptions[i])
                                            : displayOptions[i],
                                        displayOptions: displayOptions,
                                        currentStep: currentStep,
                                        pulseScale: pulseScale,
                                        shakeOffsetX: shakeX,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
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

class _ChefChoiceButton extends StatelessWidget {
  const _ChefChoiceButton({
    required this.label,
    required this.isCorrect,
    required this.isWrong,
    required this.isDisabled,
    required this.onTap,
  });

  final String label;
  final bool isCorrect;
  final bool isWrong;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors;
    final IconData? icon;
    if (isCorrect) {
      gradientColors = [Colors.green.shade400, Colors.green.shade700];
      icon = Icons.check_circle;
    } else if (isWrong) {
      gradientColors = [Colors.red.shade400, Colors.red.shade700];
      icon = Icons.cancel;
    } else if (isDisabled) {
      gradientColors = [Colors.grey.shade400, Colors.grey.shade600];
      icon = null;
    } else {
      gradientColors = [Colors.orange.shade400, Colors.deepOrange.shade600];
      icon = Icons.restaurant;
    }

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: Material(
        borderRadius: BorderRadius.circular(24),
        elevation: 4,
        shadowColor: (isCorrect ? Colors.green : isWrong ? Colors.red : Colors.orange)
            .withOpacity(0.4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientColors[0],
                  gradientColors[1],
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (icon != null && (isCorrect || isWrong)) const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
