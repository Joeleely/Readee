import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match_list/bookDetail.dart';
import 'package:readee_app/features/match_list/model/matches.dart';

class MatchedList extends StatefulWidget {
  const MatchedList({super.key});

  @override
  State<MatchedList> createState() => _MatchedListState();
}

class _MatchedListState extends State<MatchedList> {
  List<BookDetails> matchedBooks = [];
  final int userID = 2;

  Uint8List _convertBase64Image(String base64String) {
    // Remove the prefix if it exists
    String base64Data = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(base64Data);
  }

  @override
  void initState() {
    super.initState();
    fetchMatchedBooks(); // Fetch books when the page initializes
  }

  Future<void> fetchMatchedBooks() async {
    try {
      // Step 1: Get matches for the user
      final matchesResponse =
          await http.get(Uri.parse('http://localhost:3000/getMatches/$userID'));
      List<Matches> matches = [];

      if (matchesResponse.statusCode == 200) {
        final matchesData = json.decode(matchesResponse.body);
        matches = (matchesData['matches'] as List)
            .map((matchJson) => Matches.fromJson(matchJson))
            .toList();
      } else {
        throw Exception('Failed to load matches');
      }

      // Step 2: Fetch books based on matches
      List<BookDetails> fetchedMatchedBooks = [];

      for (var match in matches) {
        // print('Matches Response: ${matchesResponse.body}');

        final matchBookResponse = await http.get(
            Uri.parse('http://localhost:3000/getBook/${match.matchedBookId}'));
        if (matchBookResponse.statusCode == 200) {
          final bookJson = json.decode(matchBookResponse.body);

          fetchedMatchedBooks.add(BookDetails(
              bookId: bookJson['BookId'] ?? '',
              title: bookJson['BookName'] ?? 'Unknown Title',
              author: bookJson['Author'] ?? 'Unknown Author',
              img: [
                bookJson['BookPicture'] ?? '',
              ],
              description:
                  bookJson['BookDescription'] ?? 'No description available',
              quality: '${bookJson['Quality'] ?? '0'}%',
              genre: bookJson['Genre'] ?? ''));

          // print(fetchedBooks);
        } else {
          print('Failed to load book for ID: ${match.matchedBookId}');
        }
      }

      setState(() {
        matchedBooks = fetchedMatchedBooks; // Store the fetched books
      });
    } catch (error) {
      print('Error fetching matched books: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Matched Books'),
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      body: matchedBooks.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner when fetching data
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: matchedBooks.length,
                itemBuilder: (context, index) {
                  final book = matchedBooks[index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BookDetailPage(
                                bookId: book.bookId, userId: userID),
                          ));
                        },
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                // Check if the image is a URL or base64
                                image: book.img[0].startsWith('http')
                                    ? NetworkImage(book.img[0])
                                    : MemoryImage(
                                            _convertBase64Image(book.img[0]))
                                        as ImageProvider<Object>,
                              ),
                            ),
                          ),
                          title: Text(book.title),
                          subtitle: Text(book.author),
                        ),
                      ),
                      const Divider()
                    ],
                  );
                },
              ),
            ),
    );
  }
}
