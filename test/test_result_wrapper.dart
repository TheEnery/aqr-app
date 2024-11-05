import 'package:flutter/material.dart';

class TestResultWrapper extends StatelessWidget {
  final Widget child;

  const TestResultWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 1.0,
      widthFactor: 1.0,
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }
}
