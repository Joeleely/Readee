import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';
import 'package:readee_app/features/match_list/bookDetail.dart';
import 'package:readee_app/features/match_list/matchedList.dart';
import 'package:readee_app/features/match_list/model/matches.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';

class MatchListPage extends StatefulWidget {
  final int userId;

  const MatchListPage({super.key, required this.userId});

  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  List<BookDetails> ownerBooks = [];
  bool isLoading = true; // Loading state

  late int userID;

  Uint8List _convertBase64Image(String base64String) {
    String base64Data = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(base64Data);
  }

  @override
  void initState() {
    super.initState();
    userID = widget.userId;
    fetchMatchedBooks();
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

      // Step 2: Fetch valid matches based on TradeRequestStatus
      List<BookDetails> fetchedOwnerBooks = [];

      for (var match in matches) {
        // Fetch trade status for this matchId
        final matchStatusResponse = await http.get(
            Uri.parse('http://localhost:3000/getAllMatches/${match.matchId}'));

        if (matchStatusResponse.statusCode == 200) {
          final matchStatusData = json.decode(matchStatusResponse.body);
          var matchTradeStatus = matchStatusData['TradeRequestStatus'];

          //print(matchStatusResponse.body);
          // Debugging logs to help trace the issue
          //print('Checking matchId: ${match.matchId}, TradeRequestStatus: $matchTradeStatus');

          if (matchTradeStatus != 'rejected' && matchTradeStatus != 'accepted') {
            // Fetch books for valid matches
            final ownerBookResponse = await http.get(Uri.parse(
                'http://localhost:3000/getBook/${match.ownerBookId}'));
            final matchedBookResponse = await http.get(Uri.parse(
                'http://localhost:3000/getBook/${match.matchedBookId}'));

            if (ownerBookResponse.statusCode == 200 &&
                matchedBookResponse.statusCode == 200) {
              final ownerBookJson = json.decode(ownerBookResponse.body);
              final matchedBookJson = json.decode(matchedBookResponse.body);

              var bookDetails = BookDetails(
                bookId: ownerBookJson['BookId'] ?? '',
                title: ownerBookJson['BookName'] ?? 'Unknown Title',
                author: ownerBookJson['Author'] ?? 'Unknown Author',
                img: [ownerBookJson['BookPicture'] ?? ''],
                description: ownerBookJson['BookDescription'] ??
                    'No description available',
                quality: '${ownerBookJson['Quality'] ?? '0'}%',
                isTrade: ownerBookJson['IsTraded'],
                genre: ownerBookJson['Genre'] ?? '',
              );

              bool isDuplicate = fetchedOwnerBooks
                  .any((book) => book.bookId == bookDetails.bookId);

              if (!isDuplicate &&
                  bookDetails.isTrade == false &&
                  matchedBookJson['IsTraded'] == false) {
                fetchedOwnerBooks.add(bookDetails);
              } else {
                print(
                    'Skipping book: ${bookDetails.title} - Trade status: ${bookDetails.isTrade}');
              }
            } else {
              print(
                  'Failed to load book for ID: ${match.ownerBookId} or ${match.matchedBookId}');
            }
          } else {
            print(
                'Skipping matchId: ${match.matchId} - TradeRequestStatus: $matchTradeStatus');
          }
        } else {
          print(
              'Failed to load TradeRequestStatus for matchId: ${match.matchId}');
        }
      }

      // Update the state with the fetched books
      if (mounted) {
      setState(() {
        ownerBooks = fetchedOwnerBooks;
        isLoading = false; // Set loading to false after fetching
      });
      }
    } catch (error) {
      print('Error fetching matched books: $error');
      setState(() {
        isLoading = false; // Ensure loading is set to false on error
      });
    }
  }

  @override
  void dispose() {
    // Cancel any timers or listeners here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Match'),
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
        automaticallyImplyLeading: false,
      ),
      body: isLoading // Show loading indicator while data is being fetched
          ? const Center(child: CircularProgressIndicator())
          : ownerBooks.isEmpty
              ? const Center(child: Text("You have no book match right now"))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(
                    itemCount: ownerBooks.length,
                    itemBuilder: (context, index) {
                      final book = ownerBooks[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              CustomPageRoute(
                                  page: MatchedList(
                                userId: widget.userId,
                                bookId: book.bookId,
                              )),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: book.img[0].startsWith('http')
                                        ? NetworkImage(book.img[0])
                                        : MemoryImage(_convertBase64Image(
                                                book.img[0]))
                                            as ImageProvider<Object>,
                                  ),
                                ),
                              ),
                              title: Text(book.title),
                              subtitle: Text(book.author),
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}
