import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match_list/bookDetail.dart';
import 'package:readee_app/features/match_list/model/matches.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';

class MatchedList extends StatefulWidget {
  final int userId;
  final int bookId;
  const MatchedList({super.key, required this.userId, required this.bookId});

  @override
  State<MatchedList> createState() => _MatchedListState();
}

class _MatchedListState extends State<MatchedList> {
  List<BookDetails> matchedBooks = [];
  List<Matches> matches = [];
  List<Matches> validMatches = [];
  bool isLoading = true;

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
    fetchMatchedBooks();
  }

  Future<BookDetails?> getMatchedBookIfOwnerMatches(int matchId) async {
    try {
      final matchDataResponse = await http.get(
        Uri.parse('http://localhost:3000/getAllMatches/$matchId'),
      );

      if (matchDataResponse.statusCode == 200) {
        final matchDataJson = json.decode(matchDataResponse.body);
        var matchTradeStatus = matchDataJson['TradeRequestStatus'];
        var ownerBookId = matchDataJson['OwnerBookId'];
        var matchedBookId = matchDataJson['MatchedBookId'];
        var ownerId = matchDataJson['OwnerId']; // Get ownerId
        var matchedUserId = matchDataJson['MatchedUserId']; // Get matchedUserId

        print('Match ID: $matchId');
        print('Owner ID: $ownerId, Matched User ID: $matchedUserId');
        print('Owner Book ID: $ownerBookId, Matched Book ID: $matchedBookId');
        print('This is widget.userId: ${widget.userId}');

        // Check if ownerId matches widget.userId
        if (ownerId == widget.userId && matchTradeStatus != 'rejected') {
          if (widget.bookId == ownerBookId) {
            final matchBookResponse = await http.get(
              Uri.parse('http://localhost:3000/getBook/$matchedBookId'),
            );

            if (matchBookResponse.statusCode == 200) {
              final bookJson = json.decode(matchBookResponse.body);

              return BookDetails(
                bookId: bookJson['BookId'] ?? '',
                title: bookJson['BookName'] ?? 'Unknown Title',
                author: bookJson['Author'] ?? 'Unknown Author',
                img: [bookJson['BookPicture'] ?? ''],
                description:
                    bookJson['BookDescription'] ?? 'No description available',
                quality: '${bookJson['Quality'] ?? '0'}%',
                isTrade: bookJson['IsTraded'],
                genre: bookJson['Genre'] ?? '',
              );
            } else {
              print('Failed to load book for matchedBookId: $matchedBookId');
            }
          }
          // Owner is the current user, fetch matched book
        } else {
          if (widget.bookId == matchedBookId && matchTradeStatus != 'rejected') {
            final matchBookResponse = await http.get(
              Uri.parse('http://localhost:3000/getBook/$ownerBookId'),
            );

            if (matchBookResponse.statusCode == 200) {
              final bookJson = json.decode(matchBookResponse.body);

              return BookDetails(
                bookId: bookJson['BookId'] ?? '',
                title: bookJson['BookName'] ?? 'Unknown Title',
                author: bookJson['Author'] ?? 'Unknown Author',
                img: [bookJson['BookPicture'] ?? ''],
                description:
                    bookJson['BookDescription'] ?? 'No description available',
                quality: '${bookJson['Quality'] ?? '0'}%',
                isTrade: bookJson['IsTraded'],
                genre: bookJson['Genre'] ?? '',
              );
            } else {
              print('Failed to load book for ownerBookId: $ownerBookId');
            }
          }
          // Current user is the matched user, fetch owner's book
        }
      } else {
        print('Failed to load match data for matchId: $matchId');
      }
    } catch (error) {
      print('Error fetching matched book: $error');
    }
    return null;
  }

  Future<void> fetchMatchedBooks() async {
    try {
      final matchesResponse = await http.get(
        Uri.parse('http://localhost:3000/getMatches/${widget.userId}'),
      );

      if (matchesResponse.statusCode == 200) {
        final matchesData = json.decode(matchesResponse.body);
        matches = (matchesData['matches'] as List)
            .map((matchJson) => Matches.fromJson(matchJson))
            .toList();
      } else {
        throw Exception('Failed to load matches');
      }

      Set<String> rejectedBookIds = {};
      List<BookDetails> fetchedMatchedBooks = [];

      for (var match in matches) {
        BookDetails? bookDetails =
            await getMatchedBookIfOwnerMatches(match.matchId);

        if (bookDetails != null) {
          if (bookDetails.isTrade == false &&
              !rejectedBookIds.contains(bookDetails.bookId.toString())) {
            fetchedMatchedBooks.add(bookDetails);
            validMatches.add(match);
            print(
                "Added book: ${bookDetails.title}, BookId: ${bookDetails.bookId}, MatchId: ${match.matchId}");
          } else {
            print(
                'Skipped book: ${bookDetails.title}, Trade Status: ${bookDetails.isTrade}, Duplicate: ');
          }
        }
      }

      setState(() {
        matchedBooks = fetchedMatchedBooks;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching matched books: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Matched Books'),
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      body: isLoading // Show loading indicator while data is being fetched
          ? const Center(child: CircularProgressIndicator())
          : matchedBooks.isEmpty
              ? const Center(child: Text("You have no book match right now"))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(
                    itemCount: matchedBooks.length,
                    itemBuilder: (context, index) {
                      final book = matchedBooks[index];
                      final match = validMatches[index];

                      print(match.matchId);

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => Navigator.push(
                                context,
                                CustomPageRoute(
                                    page: BookDetailPage(
                                  bookId: book.bookId,
                                  userId: widget.userId,
                                  matchId: match.matchId,
                                  isEdit: false,
                                ))),
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
                          const Divider()
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}
