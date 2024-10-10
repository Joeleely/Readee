import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';

class BookDetailPage extends StatefulWidget {
  final int userId;
  final int bookId;

  BookDetailPage({required this.bookId, required this.userId});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Book2 book;
  late String userName;
  late int timesSwap;
  late double rating;
  late String profile;
  bool isExpanded = false;
  bool showToggle = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchBookData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users/${widget.userId}'));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          userName = userData['Username'] ?? 'ThisIsNull';
          timesSwap = userData['timesSwap'] ?? 0; // Changed to default int
          rating = userData['rating'] ?? 0.0; // Changed to default double
          profile = userData['ProfileUrl'] ?? 'ThisIsNull';
        });
      } else {
        _logError('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      _logError('Error fetching user data: $e');
    }
  }

  Future<void> _fetchBookData() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/getBook/${widget.bookId}'));

    if (response.statusCode == 200) {
      final bookData = json.decode(response.body);
      setState(() {
        book = Book2(
          title: bookData['BookName'] ?? 'ThisIsNull',
          author: bookData['Author'] ?? 'ThisIsNull',
          img: bookData['BookPicture'] is String
              ? [bookData['BookPicture']]
              : List<String>.from(bookData['BookPicture'] ?? []),
          genre: bookData['GenreId']?.toString() ?? 'ThisIsNull',
          quality: bookData['Quality']?.toString() ?? 'ThisIsNull',
          description: bookData['BookDescription'] ?? 'ThisIsNull',
          ownerId: bookData['OwnerId']?.toString() ?? 'ThisIsNull',
        );
        _checkDescriptionLength();
        isLoading = false;
      });
    } else {
      _logError('Failed to fetch book data: ${response.statusCode}');
    }
  } catch (e) {
    _logError('Error fetching book data: $e');
  }
}


  void _logError(String message) {
    // You can use your preferred logging package or service here
    print(message); // Simple logging
  }

  Uint8List _convertBase64Image(String base64String) {
    String base64Data = base64String.contains(',') ? base64String.split(',').last : base64String;
    return base64Decode(base64Data);
  }

  void _checkDescriptionLength() {
    final span = TextSpan(
      text: book.description,
      style: const TextStyle(color: Colors.grey),
    );
    final tp = TextPainter(
      text: span,
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width);

    if (tp.didExceedMaxLines) {
      setState(() {
        showToggle = true;
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure to send request?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.green),
                    minimumSize: MaterialStatePropertyAll(Size(100, 50)),
                  ),
                  onPressed: () {
                    // Handle the trade request here
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.grey),
                    minimumSize: MaterialStatePropertyAll(Size(100, 50)),
                  ),
                  child: const Text('No', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    int currentPhoto = 0; // Keep track of the current photo index

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(LineAwesomeIcons.arrow_left),
      ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Image(
                      image: book.img[currentPhoto].startsWith('http')
                          ? NetworkImage(book.img[currentPhoto])
                          : MemoryImage(_convertBase64Image(book.img[currentPhoto])) as ImageProvider<Object>,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://content.api.news/v3/images/bin/76239ca855744661be0454d51f9b9fa2?width=1024',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName),
                        Row(
                          children: [
                            Text(
                              "$timesSwap",
                              style: const TextStyle(color: Colors.cyan),
                            ),
                            const Text(" Swapped"),
                            const SizedBox(width: 10),
                            Text(
                              "$rating",
                              style: const TextStyle(color: Colors.cyan),
                            ),
                            const Text(" Ratings"),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.sms),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Author: ',
                      style: TextStyle(color: Colors.cyan),
                    ),
                    Text(book.author),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(color: Colors.cyan),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCrossFade(
                      firstChild: Text(
                        book.description,
                        maxLines: isExpanded ? null : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(book.description),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                    if (showToggle)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? "Show less" : "Show more...",
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.userId != book.ownerId)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.cyan,
                  ),
                  child: const Text(
                    'Request to trade',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Book2 {
  const Book2(
      {required this.title,
      required this.author,
      required this.img,
      required this.genre,
      required this.quality,
      required this.ownerId,
      required this.description});
  final String title;
  final String author;
  final List<String> img;
  final String genre;
  final String quality;
  final String description;
  final String ownerId;
}
