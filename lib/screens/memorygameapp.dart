import 'package:flutter/material.dart';
import 'birdgame.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> items = [
    '.444',
    '.73',
    '61',
    '1.13',
    'Tenths',
    'Hundredths',
    'Thousandths',
    'Tens'
  ];
  final Map<String, String> correctPairs = {
    '.444': 'Tenths',
    '.73': 'Hundredths',
    '61': 'Tens',
    '1.13': 'Thousandths'
  };
  List<String> selectedItems = [];

  void checkMatch() {
    if (selectedItems.length == 2) {
      final String first = selectedItems[0];
      final String second = selectedItems[1];

      // Check if the pair is correct in either order
      if ((correctPairs[first] == second) || (correctPairs[second] == first)) {
        // Correct match
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Correct!'),
          backgroundColor: Colors.green,
        ));
        setState(() {
          items.remove(first);
          items.remove(second);
        });
      } else {
        // Incorrect match
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Incorrect!'),
          backgroundColor: Colors.red,
        ));
      }
      selectedItems.clear();
    }
  }

  Widget buildUnderlinedText(String text) {
    if (text == '.444') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '.44',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '4',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '.73') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '.7',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '3',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    } else if (text == '61') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '6',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '1',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else if (text == '1.13') {
      return RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: '1.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: '1',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '3',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Play: Memory'),
        actions: [
            IconButton(
             icon: const Icon(Icons.arrow_forward_rounded),
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                     builder: (context) =>
                         const LizzieTheBirdGame()),  
               );
             },
           ),
            IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
          ),
         ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Let's play Memory! Match each underlined value to the correct units:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final String item = items[index];
                final bool isSelected = selectedItems.contains(item);
                return GestureDetector(
                  onTap: () {
                    if (selectedItems.contains(item)) return; // Prevent double-selection
                    setState(() {
                      selectedItems.add(item);
                    });
                    checkMatch();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.shade200 : Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.orange, width: 2)
                          : Border.all(color: Colors.purple, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: item.contains('.') || item == '61'
                        ? buildUnderlinedText(item)
                        : Text(
                            item,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
