import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
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
  List<BookDetails> userBooks = [];
  bool isLoading = true;
  bool isPageActive = true;

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
    fetchUserBooks();
  }

  Future<void> fetchUserBooks() async {
    try {
      final matchesResponse = await http.get(
        Uri.parse('http://localhost:3000/getMatches/$userID'),
      );

      if (matchesResponse.statusCode == 200) {
        final matchesData = json.decode(matchesResponse.body);
        final matches = (matchesData['matches'] as List)
            .map((matchJson) => Matches.fromJson(matchJson))
            .toList();

        List<BookDetails> fetchedBooks = [];

        for (var match in matches) {
          if (!isPageActive) return;

          final matchStatusResponse = await http.get(
            Uri.parse('http://localhost:3000/getAllMatches/${match.matchId}'),
          );

          if (matchStatusResponse.statusCode == 200) {
            final matchStatusData = json.decode(matchStatusResponse.body);
            final matchTradeStatus = matchStatusData['TradeRequestStatus'];
            final ownerId = matchStatusData['OwnerId'];
            final matchedUserId = matchStatusData['MatchedUserId'];
            final ownerBookId = matchStatusData['OwnerBookId'];
            final matchedBookId = matchStatusData['MatchedBookId'];

            // Ensure the trade status is not rejected
            if (matchTradeStatus == 'rejected') {
              continue;
            }

            // Determine which book to fetch based on current user's role
            int bookIdToFetch;
            if (userID == ownerId) {
              bookIdToFetch = ownerBookId;
            } else if (userID == matchedUserId) {
              bookIdToFetch = matchedBookId;
            } else {
              continue; // Skip if current user is neither owner nor matched user
            }

            // Fetch book details
            final bookResponse = await http.get(
              Uri.parse('http://localhost:3000/getBook/$bookIdToFetch'),
            );

            if (bookResponse.statusCode == 200) {
              final bookJson = json.decode(bookResponse.body);

              var bookDetails = BookDetails(
                bookId: bookJson['BookId'] ?? '',
                title: bookJson['BookName'] ?? 'Unknown Title',
                author: bookJson['Author'] ?? 'Unknown Author',
                img: [bookJson['BookPicture'] ?? ''],
                description:
                    bookJson['BookDescription'] ?? 'No description available',
                quality: '${bookJson['Quality'] ?? '0'}%',
                isTrade: bookJson['IsTraded'],
                genre: bookJson['Genre'] ?? '',
                isReport: bookJson['IsReported'],
              );

              // Ensure no duplicates and valid book
              if (!fetchedBooks
                      .any((book) => book.bookId == bookDetails.bookId) &&
                  !bookDetails.isTrade &&
                  !bookDetails.isReport) {
                fetchedBooks.add(bookDetails);
              }
            } else {
              print('Failed to load book for ID: $bookIdToFetch');
            }
          } else {
            print(
                'Failed to load TradeRequestStatus for matchId: ${match.matchId}');
          }
        }

        if (isPageActive && mounted) {
          setState(() {
            userBooks = fetchedBooks;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load matches');
      }
    } catch (error) {
      print('Error fetching user books: $error');
      if (isPageActive && mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    isPageActive = false;
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userBooks.isEmpty
              ? const Center(child: Text("You have no book match right now"))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(
                    itemCount: userBooks.length,
                    itemBuilder: (context, index) {
                      final book = userBooks[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              CustomPageRoute(
                                page: MatchedList(
                                  userId: widget.userId,
                                  bookId: book.bookId,
                                ),
                              ),
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
