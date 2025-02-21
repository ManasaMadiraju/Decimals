// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(DecimalTreasureHuntGame());
}

class DecimalTreasureHuntGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decimal Treasure Hunt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TreasureHuntScreen(),
    );
  }
}

class TreasureHuntScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _TreasureHuntScreenState createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends State<TreasureHuntScreen> with SingleTickerProviderStateMixin {
  final List<String> decimalOptions = ['0.1', '0.25', '0.5', '0.75', '1.0', '0.33', '0.67', '0.99', '0.01', '0.005', '0.125', '0.875'];
  String targetDecimal = '0.5';
  String decimalPlace = 'tenths'; // Default to tenths
  bool isTreasureFound = false;
  int score = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    setTargetDecimal();
  }

  // Function to set target decimal dynamically
  void setTargetDecimal() {
    if (decimalPlace == 'tenths') {
      targetDecimal = decimalOptions[(decimalOptions.indexOf(targetDecimal) + 1) % 5];
    } else if (decimalPlace == 'hundredths') {
      targetDecimal = decimalOptions[(decimalOptions.indexOf(targetDecimal) + 1) % 8];
    } else if (decimalPlace == 'thousandths') {
      targetDecimal = decimalOptions[(decimalOptions.indexOf(targetDecimal) + 1) % decimalOptions.length];
    }
  }

  // Function to get the decimal place text
  String getDecimalPlaceText() {
    switch (decimalPlace) {
      case 'tenths':
        return 'tenths';
      case 'hundredths':
        return 'hundredths';
      case 'thousandths':
        return 'thousandths';
      default:
        return 'decimal';
    }
  }

  Future<void> playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void checkDecimal(String selectedDecimal) async {
    if (selectedDecimal == targetDecimal) {
      setState(() {
        isTreasureFound = true;
        score += 10;
      });
      await playSound('sounds/success.mp3');
      _animationController.forward(from: 0);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Treasure Found!', style: TextStyle(color: Colors.green)),
            content: Text('Congratulations! You found $targetDecimal in $decimalPlace.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
                child: const Text('Next Round', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
      }
    } else {
      await playSound('sounds/error.mp3');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Try Again', style: TextStyle(color: Colors.red)),
            content: const Text("Oops! That's not the correct decimal. Try again!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
      }
    }
  }

  void resetGame() {
    setState(() {
      isTreasureFound = false;
      setTargetDecimal();
      _animationController.reset();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decimal Treasure Hunt'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 30),
                const SizedBox(width: 5),
                Text('Score: $score', style: const TextStyle(fontSize: 20, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade300],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Find the decimal in ${getDecimalPlaceText()}:', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(targetDecimal, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: decimalOptions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => checkDecimal(decimalOptions[index]),
                      child: ScaleTransition(
                        scale: _animation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, offset: const Offset(2, 2)),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              decimalOptions[index],
                              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// // ignore_for_file: use_key_in_widget_constructors

// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';

// void main() {
//   runApp(DecimalTreasureHuntGame());
// }

// class DecimalTreasureHuntGame extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Decimal Treasure Hunt',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: TreasureHuntScreen(),
//     );
//   }
// }

// class TreasureHuntScreen extends StatefulWidget {
//   @override
//   // ignore: library_private_types_in_public_api
//   _TreasureHuntScreenState createState() => _TreasureHuntScreenState();
// }

// class _TreasureHuntScreenState extends State<TreasureHuntScreen> with SingleTickerProviderStateMixin {
//   final List<String> decimalOptions = ['0.1', '0.25', '0.5', '0.75', '1.0', '0.33', '0.67', '0.99', '0.01'];
//   String targetDecimal = '0.5';
//   bool isTreasureFound = false;
//   int score = 0;
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }

//   Future<void> playSound(String soundPath) async {
//     try {
//       await _audioPlayer.play(AssetSource(soundPath));
//     } catch (e) {
//       print("Error playing sound: $e");
//     }
//   }

//   void checkDecimal(String selectedDecimal) async {
//     if (selectedDecimal == targetDecimal) {
//       setState(() {
//         isTreasureFound = true;
//         score += 10;
//       });
//       await playSound('sounds/success.mp3');
//       _animationController.forward(from: 0);
      
//       if (mounted) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Treasure Found!', style: TextStyle(color: Colors.green)),
//             content: Text('Congratulations! You found $targetDecimal.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   resetGame();
//                 },
//                 child: const Text('Next Round', style: TextStyle(color: Colors.blue)),
//               ),
//             ],
//           ),
//         );
//       }
//     } else {
//       await playSound('sounds/error.mp3');
//       if (mounted) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Try Again', style: TextStyle(color: Colors.red)),
//             content: const Text("Oops! That's not the correct decimal. Try again!"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK', style: TextStyle(color: Colors.blue)),
//               ),
//             ],
//           ),
//         );
//       }
//     }
//   }

//   void resetGame() {
//     setState(() {
//       isTreasureFound = false;
//       targetDecimal = decimalOptions[(decimalOptions.indexOf(targetDecimal) + 1) % decimalOptions.length];
//       _animationController.reset();
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Decimal Treasure Hunt'),
//         backgroundColor: Colors.blueAccent,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Icon(Icons.star, color: Colors.yellow, size: 30),
//                 SizedBox(width: 5),
//                 Text('Score: $score', style: TextStyle(fontSize: 20, color: Colors.white)),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue.shade100, Colors.blue.shade300],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Text('Find the decimal:', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),
//               Text(targetDecimal, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
//               SizedBox(height: 20),
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                   ),
//                   itemCount: decimalOptions.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () => checkDecimal(decimalOptions[index]),
//                       child: ScaleTransition(
//                         scale: _animation,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.amber.shade600,
//                             borderRadius: BorderRadius.circular(15),
//                             boxShadow: [
//                               BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, offset: Offset(2, 2)),
//                             ],
//                           ),
//                           child: Center(
//                             child: Text(
//                               decimalOptions[index],
//                               style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
