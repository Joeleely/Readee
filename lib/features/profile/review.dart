import 'package:flutter/material.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';
import 'package:readee_app/features/profile/yourRating.dart';
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
        backgroundColor: Color.fromARGB(255, 228, 248, 255),
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
                  CustomPageRoute(
                      page: YourReviewPage(
                    userId: widget.userID,
                  )),
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
                  CustomPageRoute(
                      page: YourRatingPage(
                    userId: widget.userID,
                  )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
