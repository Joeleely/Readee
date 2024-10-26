import 'package:flutter/material.dart';

class YourReviewPage extends StatefulWidget {
  const YourReviewPage({super.key});

  @override
  State<YourReviewPage> createState() => _YourReviewPageState();
}

class _YourReviewPageState extends State<YourReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Review'),
      ),
      body: const Center(child: Text('Your Review Page')),
    );
  }
}
