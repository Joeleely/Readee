import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readee_app/typography.dart';

class YourReviewPage extends StatefulWidget {
  const YourReviewPage({super.key});

  @override
  State<YourReviewPage> createState() => _YourReviewPageState();
}

class _YourReviewPageState extends State<YourReviewPage> {
  late Future<List<Review>> reviewsFuture;

  @override
  void initState() {
    super.initState();
    reviewsFuture = fetchReviews();
  }

  Future<List<Review>> fetchReviews() async {
    final response = await http.get(Uri.parse('http://localhost:3000/reviews/given/1'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['reviews'];
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Review>>(
          future: reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No reviews available'));
            } else {
              final reviews = snapshot.data!;
              return ListView.separated(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return ReviewCard(review: reviews[index]);
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                    height: 32,
                  );
                },
              );
            }
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

  // Factory method to create a Review object from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      username: json['receiver_name'],
      profileImageUrl: json['receiver_picture'] ?? 'https://example.com/placeholder.jpg', // Placeholder if image is null
      bookName: json['receiver_book_name'] ?? 'Unknown Book',
      comment: json['review'],
      rating: json['rating'],
    );
  }
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
