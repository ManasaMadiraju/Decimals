import 'package:flutter/material.dart';
import 'dart:async'; // 👈 Add this for Timer


 void showCustomAnimatedDialog(BuildContext context, String message, {bool isSuccess = true}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true, // 👈 Add this
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => _CustomDialog(message: message, isSuccess: isSuccess), 
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ),
  );
}



class _CustomDialog extends StatefulWidget {
  final String message;
  final bool isSuccess;

  const _CustomDialog({Key? key, required this.message, required this.isSuccess}) : super(key: key);

  @override
  State<_CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<_CustomDialog> {
  @override
  @override
   void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      Navigator.of(context).pop(); // 👈 This dismisses the custom dialog automatically!
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: widget.isSuccess ? Colors.green : Colors.red,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                widget.isSuccess ? 'Success!' : 'Oops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
