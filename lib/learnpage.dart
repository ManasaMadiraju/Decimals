import 'package:flutter/material.dart';
import 'learnpage2.dart';

class LearnPage extends StatelessWidget {
   const LearnPage({super.key});

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('Introduction'),
         backgroundColor: Colors.green,
         actions: [
            IconButton(
             icon: const Icon(Icons.arrow_forward_rounded),
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                     builder: (context) =>
                         LearnPage2()),  
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
       body: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
            const Center (
             child: Text(
               'What are Decimals?',
               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
             ),
            ),
             const SizedBox(height: 20),
             const Text(
               'Decimals are a way of expressing numbers that are not whole numbers. They are numbers with a dot, called a decimal point. The decimal point separates whole numbers from parts of a number.',
               style: TextStyle(fontSize: 18),
             ),
             const SizedBox(height: 20),
             const Text(
               'Decimal Example:\n'
               '0.1 means one-tenth, 0.01 means one-hundredth, and so on.',
               style: TextStyle(fontSize: 18),
             ),
             const SizedBox(height: 30),  
             Center ( 
             child: Image.asset(
               'assets/decimal1.png', 
               width: 200, 
               height: 100,  
               fit: BoxFit.cover,
             ),
             ),
             const SizedBox(height: 20),
             Row(
               mainAxisAlignment: MainAxisAlignment.end, // Aligns the button to the left
               children: [
                 ElevatedButton(
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) =>  LearnPage2()),
                     );
                   },
                   child: const Text('Next Page'),
                 ),
               ],
             ),
           ],
         ),
       ),
     );
   }
}