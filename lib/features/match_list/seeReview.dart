import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SeeReviewPage extends StatefulWidget {
  final String userId;
  final String OwnerName;

  SeeReviewPage({Key? key, required this.userId, required this.OwnerName}) : super(key: key);

  @override
  State<SeeReviewPage> createState() => _SeeReviewPageState();
}

class _SeeReviewPageState extends State<SeeReviewPage> {
  late final String reviewsApiUrl;
  late final String averageRatingApiUrl;

  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    //reviewsApiUrl = 'http://localhost:3000/reviews/received/${widget.userId}';
    //averageRatingApiUrl = 'http://localhost:3000/avgRating/${widget.userId}';

    // Fetch the average rating when the page loads
    fetchAverageRating();
  }

  Future<List<Rating>> fetchReviews() async {
    try {
      print('Fetching reviews...');
      final response = await http
          .get(Uri.parse(
              'http://localhost:3000/reviews/received/${widget.userId}'))
          .timeout(const Duration(seconds: 10));
      ;
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('reviews')) {
          final List<dynamic> reviewsData = responseData['reviews'];
          //print('Reviews found: $reviewsData');
          return reviewsData.map((json) => Rating.fromJson(json)).toList();
        } else if (responseData.containsKey('message')) {
          //print('No reviews message: ${responseData['message']}');
          return [];
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to load reviews. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchReviews: $e');
      return [];
    }
  }

  Future<void> fetchAverageRating() async {
  try {
    final response = await http
        .get(Uri.parse('http://localhost:3000/avgRating/${widget.userId}'))
        .timeout(const Duration(seconds: 10)); // Add timeout for robustness

    if (response.statusCode == 200) {
      setState(() {
        averageRating = json.decode(response.body)['average_rating'] ?? 0;
        print("averageRating: $averageRating");
      });
    } else if (response.statusCode == 404) {
      // Handle 404 (not found) specifically
      setState(() {
        averageRating = 0.0; // Default to 0.0 if no rating exists
      });
      print("averageRating not found for userId: ${widget.userId}");
    } else {
      throw Exception('Failed to load average rating. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching average rating: $e');
    setState(() {
      averageRating = 0.0; // Handle errors gracefully by setting default value
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.OwnerName}"),
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
                  print('FutureBuilder State: ${snapshot.connectionState}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print('State: Error');
                    print('Error: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print('State: No Data');
                    return const Center(
                      child: Text(
                        'This user hasn\'t received any reviews yet.',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    );
                  } else {
                    print('State: Data Found');
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
      profileImageUrl:
          json['giver_picture'] ?? 'https://example.com/placeholder.jpg',
      comment: json['review'] ?? '',
      rating: json['score'] ?? 0,
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
