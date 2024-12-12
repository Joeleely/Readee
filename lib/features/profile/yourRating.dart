import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class YourRatingPage extends StatefulWidget {
  final int userId;

  YourRatingPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<YourRatingPage> createState() => _YourRatingPageState();
}

class _YourRatingPageState extends State<YourRatingPage> {
  late final String reviewsApiUrl;
  late final String averageRatingApiUrl;

  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    reviewsApiUrl =
        'https://readee-api.stthi.com/reviews/received/${widget.userId}';
    averageRatingApiUrl =
        'https://readee-api.stthi.com/avgRating/${widget.userId}';

    // Fetch the average rating when the page loads
    fetchAverageRating();
  }

  Future<List<Rating>> fetchReviews() async {
    final response = await http.get(Uri.parse(reviewsApiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['reviews'] ?? [];
      List<Rating> reviews = data.map((json) => Rating.fromJson(json)).toList();
      // Debugging to check values
      for (var review in reviews) {
        print("Review Rating: ${review.rating}");
      }
      return reviews;
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> fetchAverageRating() async {
    final response = await http.get(Uri.parse(averageRatingApiUrl));

    if (response.statusCode == 200) {
      setState(() {
        averageRating =
            (json.decode(response.body)['average_rating'] ?? 0.0).toDouble();
      });
    } else {
      throw Exception('Failed to load average rating');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your rating'),
        backgroundColor: Color.fromARGB(255, 228, 248, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying the Average Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < averageRating.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 30,
                );
              }),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Average: ${averageRating.toStringAsFixed(1)}',
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
              child: FutureBuilder<List<Rating>>(
                future: fetchReviews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                            'You currently have no reviews or ratings \n from other users.'));
                  } else {
                    final reviews = snapshot.data!;
                    return ListView.separated(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return RatingCard(review: reviews[index]);
                      },
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.grey,
                        height: 32,
                        thickness: 0.5,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Rating {
  final String username;
  final String profileImageUrl;
  final String comment;
  final int rating;
  final int score;

  Rating({
    required this.username,
    required this.profileImageUrl,
    required this.comment,
    required this.rating,
    required this.score,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      username: json['giver_name'] ?? 'Unknown User',
      profileImageUrl:
          json['giver_picture'] ?? 'https://example.com/placeholder.jpg',
      comment: json['review'] ?? '',
      rating: (json['rating'] ?? 0),
      score: (json['score'] ?? 0),
    );
  }
}

class RatingCard extends StatelessWidget {
  final Rating review;

  const RatingCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Rating: ${review.rating}');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(review.profileImageUrl),
          onBackgroundImageError: (_, __) =>
              const AssetImage('assets/placeholder.png'),
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
        // Generate stars based on the rating
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < review.score ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 18,
            );
          }),
        ),
      ],
    );
  }
}
