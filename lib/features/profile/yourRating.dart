import 'package:flutter/material.dart';

class YourRatingPage extends StatelessWidget {
  final double averageRating = 3.0;
  final List<Review> reviews = [
    Review(
      username: 'Marshmallow',
      profileImageUrl: 'https://content.api.news/v3/images/bin/76239ca855744661be0454d51f9b9fa2?width=1024',
      comment: 'คุยง่าย ไม่โกง',
      rating: 5,
    ),
    Review(
      username: 'Alan Walker',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/11.jpg',
      comment: 'He is lying',
      rating: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your rating'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Average Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Average: $averageRating',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Reviews Title
            const Text(
              'Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // List of Reviews
            Expanded(
              child: ListView.separated(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return ReviewCard(review: reviews[index]);
                },
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                  height: 32,
                  thickness: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Review {
  final String username;
  final String profileImageUrl;
  final String comment;
  final int rating;

  Review({
    required this.username,
    required this.profileImageUrl,
    required this.comment,
    required this.rating,
  });
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(review.profileImageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.lightBlue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.comment,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < review.rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 18,
            );
          }),
        ),
      ],
    );
  }
}
