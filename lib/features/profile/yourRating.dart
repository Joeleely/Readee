import 'dart:convert';
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
    reviewsApiUrl = 'http://localhost:3000/reviews/received/${widget.userId}';
    averageRatingApiUrl = 'http://localhost:3000/avgRating/${widget.userId}';

    // Fetch the average rating when the page loads
    fetchAverageRating();
  }

  Future<List<Rating>> fetchReviews() async {
    final response = await http.get(Uri.parse(reviewsApiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['reviews'];
      return data.map((json) => Rating.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> fetchAverageRating() async {
    final response = await http.get(Uri.parse(averageRatingApiUrl));

    if (response.statusCode == 200) {
      setState(() {
        averageRating = json.decode(response.body)['average_rating'];
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
                    return const Center(child: Text('No reviews available'));
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

  Rating({
    required this.username,
    required this.profileImageUrl,
    required this.comment,
    required this.rating,
  });

  // Factory method to create a Rating object from JSON
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      username: json['giver_name'],
      profileImageUrl: json['giver_picture'],
      comment: json['review'],
      rating: json['rating'],
    );
  }
}

class RatingCard extends StatelessWidget {
  final Rating review;

  const RatingCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
