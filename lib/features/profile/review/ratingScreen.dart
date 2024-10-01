import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({Key? key}) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Rating'),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.red,
                child: Center(child: Text('Column 1')),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.green,
                child: Center(child: Text('Column 2')),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.blue,
                child: Center(child: Text('Column 3')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}