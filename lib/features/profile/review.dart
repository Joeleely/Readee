import 'package:flutter/material.dart';
import 'package:readee_app/features/profile/yourReview.dart';

class ReviewPage extends StatefulWidget {
  final int userID;
  const ReviewPage({super.key, required this.userID});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Your Review'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const YourReviewPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Your Rating'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const YourReviewPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


