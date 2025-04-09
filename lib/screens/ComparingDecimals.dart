import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compare Decimals',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CompareDecimals(),
    );
  }
}

class CompareDecimals extends StatefulWidget {
  @override
  _CompareDecimalsState createState() => _CompareDecimalsState();
}

class _CompareDecimalsState extends State<CompareDecimals> {
  double number1 = 2.45;
  double number2 = 2.67;
  String resultMessage = '';
  bool showExplanation = true;

  void compareDecimals() {
    if (number1 > number2) {
      setState(() {
        resultMessage = '✨ Number 1 ($number1) is greater! ✨';
      });
    } else if (number1 < number2) {
      setState(() {
        resultMessage = '✨ Number 2 ($number2) is greater! ✨';
      });
    } else {
      setState(() {
        resultMessage = '🎉 Both numbers are equal! 🎉';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
        title: Text('Compare Decimals', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.green,
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (showExplanation)
              AnimatedOpacity(
                opacity: showExplanation ? 1.0 : 0.0,
                duration: Duration(seconds: 1),
                child: Column(
                  children: [
                    Text(
                      'Comparing Decimals',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Decimals are numbers with a whole part and a fractional part. For example, 2.5 has 2 as the whole part and 0.5 as the fractional part.\n\n'
                      '1. Compare the whole numbers: The bigger whole number is greater.\n'
                      '2. If the whole numbers are the same, compare the fractional part: The bigger decimal part is greater.\n\n'
                      'Example: 3.7 > 3.5 because 7 > 5.\n\nLet\'s practice comparing decimals!',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showExplanation = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'Got it! Let\'s Compare!',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            else
              AnimatedOpacity(
                opacity: showExplanation ? 0.0 : 1.0,
                duration: Duration(seconds: 1),
                child: Column(
                  children: [
                    Text(
                      'Which decimal is greater?',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Decimal 1: $number1',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Decimal 2: $number2',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: compareDecimals,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'Compare',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      resultMessage,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
