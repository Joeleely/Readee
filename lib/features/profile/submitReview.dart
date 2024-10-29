import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RateAndReviewPage extends StatefulWidget {
  final int giverId;
  final int receiverId;
  final String bookName;
  final String giverBookImage;
  final String receiverBookImage;
  final String matchedBookName;

  const RateAndReviewPage({
    super.key,
    required this.giverId,
    required this.receiverId,
    required this.bookName,
    required this.giverBookImage,
    required this.receiverBookImage,
    required this.matchedBookName,
  });

  @override
  _RateAndReviewPageState createState() => _RateAndReviewPageState();
}

class _RateAndReviewPageState extends State<RateAndReviewPage> {
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    fetchExistingReview();
  }

  Future<void> fetchExistingReview() async {
    final url = Uri.parse(
        "http://localhost:3000/get_review_rating/${widget.giverId}/${widget.receiverId}");

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer <Your-Token>",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          rating = data['rating'] ?? 0;
          reviewController.text = data['review'] ?? '';
          isSubmitted = true;
        });
      } else if (response.statusCode == 404) {
        // No existing review found, allow user to add a new one
        setState(() {
          isSubmitted = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch existing review")),
        );
      }
    } catch (e) {
      print("Error fetching review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching review")),
      );
    }
  }

  Future<void> submitReview() async {
    if (widget.receiverId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Invalid matched user ID")),
      );
      return;
    }

    final url = Uri.parse("http://localhost:3000/review_rating");

    final body = jsonEncode({
      "giver_id": widget.giverId,
      "receiver_id": widget.receiverId,
      "new_score": rating,
      "text_review": reviewController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer <Your-Token>",
        },
        body: body,
      );

      if (response.statusCode == 201) {
        setState(() {
          isSubmitted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully submitted!")),
        );

        // Unfocus the text field to remove the cursor
        FocusScope.of(context).unfocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error submitting review: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rate and Review"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    _buildImageContainer(widget.giverBookImage),
                    SizedBox(height: 5),
                    Text(
                      widget.bookName,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    _buildImageContainer(widget.receiverBookImage),
                    SizedBox(height: 5),
                    Text(
                      widget.matchedBookName,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                  ),
                  onPressed: isSubmitted
                      ? null
                      : () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                );
              }),
            ),
            SizedBox(height: 20),
            TextField(
              controller: reviewController,
              decoration: InputDecoration(
                hintText: "Add your review",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              readOnly: isSubmitted, // Disable editing if submitted
            ),
            SizedBox(height: 20),
            isSubmitted
                ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: Text("Submitted"),
                  )
                : ElevatedButton(
                    onPressed: submitReview,
                    child: Text("Submit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(String imageUrl) {
    return Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: imageUrl.startsWith("http")
              ? NetworkImage(imageUrl)
              : MemoryImage(base64Decode(imageUrl)) as ImageProvider,
        ),
      ),
    );
  }
}
