import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';


class ReadingDecimalScreen extends StatelessWidget {
  const ReadingDecimalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: const Text('Reading Decimals'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'To read decimals:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '1. Say the whole number first.\n'
              '2. Say “and.”\n'
              '3. Say each number after the decimal.\n'
              '4. Don’t forget to say the units of the last digit!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            const Text(
              'Examples:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ExampleItem(
              number: '12.7',
              description: 'Twelve and seven tenths',
            ),
            ExampleItem(
              number: '38.29',
              description: 'Thirty Eight and Twenty Nine Hundredths',
            ),
            ExampleItem(
              number: '453.01',
              description: 'Four Hundred Fifty Three and One Hundredths',
            ),
          ],
        ),
      ),
    );
  }
}
class ExampleItem extends StatelessWidget {
  final String number;
  final String description;

  ExampleItem({
    required this.number,
    required this.description,
    super.key,
  });

  final FlutterTts _flutterTts = FlutterTts();


  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Audio button
          IconButton(
            onPressed: () => _speak(number),
            icon: const Icon(Icons.volume_up),
            color: Colors.orange,
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}