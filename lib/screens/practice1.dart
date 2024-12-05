// import 'package:flutter/material.dart';

// class PlaceValueScreen extends StatefulWidget {
//   @override
//   _PlaceValueScreenState createState() => _PlaceValueScreenState();
// }

// class _PlaceValueScreenState extends State<PlaceValueScreen> {
//   final Map<String, String> items = {
//     '1': 'Tens',
//     '7': 'Ones',
//     '6': 'Tenths',
//     '2': 'Hundredths',
//     '5': 'Thousandths',
//   };

//   final List<String> extraOptions = [
//     'Thousands',
//     'Hundreds',
//     'Teen',
//     'Oneths',
//     'Sevenths',
//   ];

//   final Map<String, String> draggedItems = {};
//   final Map<String, bool> feedback = {};

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Practice Test 1: Score 0'),
//         backgroundColor: Colors.green,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               "Match Each Number with its Place Value:",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20),
//             // Numbers with Drop Targets Below
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: items.keys.map((key) {
//                 return Column(
//                   children: [
//                     _buildColoredNumber(key, _getColorForNumber(key)),
//                     SizedBox(height: 10),
//                     _buildDragTarget(key),
//                   ],
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 40),
//             // Feedback Section
//             Column(
//               children: feedback.keys.map((key) {
//                 return Text(
//                   feedback[key]! ? "Correct for $key!" : "Incorrect for $key!",
//                   style: TextStyle(
//                     color: feedback[key]! ? Colors.green : Colors.red,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 20),
//             // Draggable Options
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               alignment: WrapAlignment.center,
//               children: [
//                 ...items.values,
//                 ...extraOptions,
//               ].map((value) => _buildDraggable(value)).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget for colored numbers
//   Widget _buildColoredNumber(String number, Color color) {
//     return Text(
//       number,
//       style: TextStyle(
//         fontSize: 40,
//         fontWeight: FontWeight.bold,
//         color: color,
//       ),
//     );
//   }

//   // Widget for draggable options
//   Widget _buildDraggable(String value) {
//     return Draggable<String>(
//       data: value,
//       feedback: Material(
//         child: Container(
//           padding: EdgeInsets.all(8),
//           color: Colors.grey[300],
//           child: Text(
//             value,
//             style: TextStyle(fontSize: 16),
//           ),
//         ),
//       ),
//       childWhenDragging: Container(
//         padding: EdgeInsets.all(8),
//         color: Colors.grey[200],
//         child: Text(
//           value,
//           style: TextStyle(fontSize: 16, color: Colors.grey),
//         ),
//       ),
//       child: Container(
//         padding: EdgeInsets.all(8),
//         color: Colors.grey[300],
//         child: Text(
//           value,
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }

//   // Widget for drag targets
//   Widget _buildDragTarget(String key) {
//     return DragTarget<String>(
//       onAccept: (value) {
//         setState(() {
//           if (items[key] == value) {
//             draggedItems[key] = value;
//             feedback[key] = true; // Correct feedback
//           } else {
//             feedback[key] = false; // Incorrect feedback
//           }
//         });
//       },
//       builder: (context, candidateData, rejectedData) {
//         return Container(
//           width: 100,
//           height: 50,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(8),
//             color: draggedItems[key] != null
//                 ? Colors.green[100]
//                 : Colors.white,
//           ),
//           alignment: Alignment.center,
//           child: draggedItems[key] != null
//               ? Text(
//                   draggedItems[key]!,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 )
//               : Text(
//                   'Drop here',
//                   style: TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//         );
//       },
//     );
//   }

//   // Helper function to get color for numbers
//   Color _getColorForNumber(String number) {
//     switch (number) {
//       case '1':
//       case '7':
//         return Colors.red;
//       case '6':
//         return Colors.green;
//       case '2':
//         return Colors.blue;
//       case '5':
//         return Colors.brown;
//       default:
//         return Colors.black;
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'dart:math';

class PlaceValueScreen extends StatefulWidget {
  @override
  _PlaceValueScreenState createState() => _PlaceValueScreenState();
}

class _PlaceValueScreenState extends State<PlaceValueScreen> {
  final Map<String, String> items = {
    '1': 'Tens',
    '7': 'Ones',
    '6': 'Tenths',
    '2': 'Hundredths',
    '5': 'Thousandths',
  };

  final List<String> extraOptions = [
    'Seven',
    'Thousands',
    'Hundreds',
    'Teen',
    'Oneths',
    'Sevenths',
  ];

  final Map<String, String> draggedItems = {};
  final Map<String, bool> feedback = {};

  @override
  Widget build(BuildContext context) {
  // Combine and shuffle options
  final shuffledOptions = [...items.values, ...extraOptions]..shuffle(Random());
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Test 1: Score 0'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Match Each Number with its Place Value:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Numbers with Drop Targets Below
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _buildColoredNumber('1', Colors.red),
                    SizedBox(height: 10),
                    _buildDragTarget('1'),
                  ],
                ),
                Column(
                  children: [
                    _buildColoredNumber('7', Colors.red),
                    SizedBox(height: 10),
                    _buildDragTarget('7'),
                  ],
                ),
                Column(
                  children: [
                    _buildColoredNumber('.', Colors.black),
                    SizedBox(height: 60),
                    //  _buildDragTarget('.'),
                  ],
                ),
                Column(
                  children: [
                    _buildColoredNumber('6', Colors.green),
                    SizedBox(height: 10),
                    _buildDragTarget('6'),
                  ],
                ),
                Column(
                  children: [
                    _buildColoredNumber('2', Colors.blue),
                    SizedBox(height: 10),
                    _buildDragTarget('2'),
                  ],
                ),
                Column(
                  children: [
                    _buildColoredNumber('5', Colors.brown),
                    SizedBox(height: 10),
                    _buildDragTarget('5'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            // Feedback Section
            Column(
              children: feedback.keys.map((key) {
                return Text(
                  feedback[key]! ? "Correct for $key!" : "Incorrect for $key!",
                  style: TextStyle(
                    color: feedback[key]! ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            // Draggable Options
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: shuffledOptions.map((value) => _buildDraggable(value)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for colored numbers
  Widget _buildColoredNumber(String number, Color color) {
    return Text(
      number,
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  // Widget for draggable options
  Widget _buildDraggable(String value) {
    return Draggable<String>(
      data: value,
      feedback: Material(
        child: Container(
          padding: EdgeInsets.all(8),
          color: Colors.grey[300],
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: EdgeInsets.all(8),
        color: Colors.grey[200],
        child: Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(8),
        color: Colors.grey[300],
        child: Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // Widget for drag targets
  Widget _buildDragTarget(String key) {
    return DragTarget<String>(
      onAccept: (value) {
        setState(() {
          if (items[key] == value) {
            draggedItems[key] = value;
            feedback[key] = true; // Correct feedback
          } else {
            feedback[key] = false; // Incorrect feedback
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: draggedItems[key] != null
                ? Colors.green[100]
                : Colors.white,
          ),
          alignment: Alignment.center,
          child: draggedItems[key] != null
              ? Text(
                  draggedItems[key]!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              : Text(
                  'Drop here',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
        );
      },
    );
  }
}
