import 'package:flutter/material.dart';

class ReturningUserRestrictedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'The app is only available in Thailand. You can use it again when you’re back in Thailand.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
