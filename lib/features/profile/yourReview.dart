import 'package:flutter/material.dart';
import 'package:readee_app/typography.dart';

class YourReviewPage extends StatefulWidget {
  const YourReviewPage({super.key});

  @override
  State<YourReviewPage> createState() => _YourReviewPageState();
}

class _YourReviewPageState extends State<YourReviewPage> {
  final List<Review> reviews = [
    Review(
      username: 'Joe',
      profileImageUrl:
          'https://content.api.news/v3/images/bin/76239ca855744661be0454d51f9b9fa2?width=1024',
      bookName: 'Book 1',
      comment: 'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
      rating: 5,
    ),
    Review(
      username: 'Emma',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/45.jpg',
      bookName: 'Book 2',
      comment: 'A great read, highly recommend!',
      rating: 4,
    ),
     Review(
      username: 'Emma',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/45.jpg',
      bookName: 'Book 2',
      comment: 'A great read, highly recommend!',
      rating: 4,
    ),
     Review(
      username: 'Emma',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/45.jpg',
      bookName: 'Book 2',
      comment: 'A great read, highly recommend!',
      rating: 4,
    ),
    // Add more reviews here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.separated(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return ReviewCard(review: review);
          },
          separatorBuilder: (context, index) {
            return const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 32,
            );
          },
        ),
      ),
    );
  }
}



class Review {
  final String username;
  final String profileImageUrl;
  final String bookName;
  final String comment;
  final int rating;

  Review({
    required this.username,
    required this.profileImageUrl,
    required this.bookName,
    required this.comment,
    required this.rating,
  });
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(review.profileImageUrl),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: List.generate(review.rating, (index) {
                    return const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  review.bookName,
                  style: TypographyText.h3(Colors.black),
                ),
                Text(
                  review.comment,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
