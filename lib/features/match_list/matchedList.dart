import 'dart:async';
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
  Timer? _timer;

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
    _timer =
        Timer.periodic(const Duration(minutes: 1), (_) => checkForExpiry());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  void checkForExpiry() {
    final now = DateTime.now();
    for (var match in validMatches) {
      // Ensure that matchedTime is not null before using it
      if (match.matchTime != null) {
        final matchTime =
            match.matchTime; // Assuming matchedTime is of type DateTime
        if (now.difference(matchTime).inDays >= 7) {
          rejectMatch(match.matchId, match.matchedBookId, widget.userId);
        }
      } else {
        print('Matched time is null for matchId: ${match.matchId}');
      }
    }
  }

  Future<void> rejectMatch(int matchId, int matchedBookId, int userId,
      {bool silent = false}) async {
    // First, reject the match
    final response = await http.post(
      Uri.parse('http://localhost:3000/trades/$matchId/reject'),
    );

    if (response.statusCode == 200) {
      // Second, log the unlike action after rejection
      final unlikeResponse = await http.post(
        Uri.parse('http://localhost:3000/unlikeLogs/$matchedBookId/$userId'),
      );

      if (unlikeResponse.statusCode == 200) {
        setState(() {
          // Find the index of the match to remove it safely
          int index =
              validMatches.indexWhere((match) => match.matchId == matchId);
          if (index != -1) {
            validMatches.removeAt(index);
            matchedBooks.removeAt(index);
          }

          print("this is validMatches: $validMatches");
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match rejected successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log the unlike action')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reject the match')),
      );
    }
  }

  Future<void> showRejectConfirmation(
      int matchId, int matchedBookId, int userId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Match"),
        content: const Text("Are you sure you want to reject this match?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              "Reject",
              style: TextStyle(color: Colors.red),
            ),
            //style: ButtonStyle(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      rejectMatch(matchId, matchedBookId, userId);
    }
  }

  Future<BookDetails?> getMatchedBookIfOwnerMatches(int matchId) async {
    try {
      // Fetch match details from the API
      final matchDataResponse = await http.get(
        Uri.parse('http://localhost:3000/getAllMatches/$matchId'),
      );

      if (matchDataResponse.statusCode != 200) {
        print('Failed to load match data for matchId: $matchId');
        return null;
      }

      final matchDataJson = json.decode(matchDataResponse.body);
      final matchTradeStatus = matchDataJson['TradeRequestStatus'];
      final ownerBookId = matchDataJson['OwnerBookId'];
      final matchedBookId = matchDataJson['MatchedBookId'];
      final ownerId = matchDataJson['OwnerId'];
      final matchUserId = matchDataJson['MatchedUserId'];

      // Debugging information
      print('Match ID: $matchId');
      print('Owner ID: $ownerId, Matched User ID: $matchUserId');
      print('Owner Book ID: $ownerBookId, Matched Book ID: $matchedBookId');
      print('Trade Request Status: $matchTradeStatus');
      print('Current User ID: ${widget.userId}');

      // Ensure trade status is not "rejected"
      if (matchTradeStatus == 'rejected') {
        print('Trade status is rejected for matchId: $matchId');
        return null;
      }

      // Case 1: Current user is the owner
      if (widget.userId == ownerId) {
        // Fetch the matched book (book belonging to the matched user)
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
            isReport: bookJson['IsReported'],
          );
        } else {
          print('Failed to load book for matchedBookId: $matchedBookId');
        }
      }
      // Case 2: Current user is the matched user
      else if (widget.userId == matchUserId) {
        // Fetch the owner's book (book belonging to the owner)
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
            isReport: bookJson['IsReported'],
          );
        } else {
          print('Failed to load book for ownerBookId: $ownerBookId');
        }
      } else {
        // Neither owner nor matched user
        print('Current user is not part of this match: $matchId');
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
      Set<String> processedBookIds = {};

      for (var match in matches) {
        BookDetails? bookDetails =
            await getMatchedBookIfOwnerMatches(match.matchId);

        if (bookDetails != null) {
          String bookIdStr =
              bookDetails.bookId.toString(); // Ensure consistent representation

          if (!bookDetails.isTrade &&
              !rejectedBookIds.contains(bookIdStr) &&
              !processedBookIds.contains(bookIdStr)) {
            fetchedMatchedBooks.add(bookDetails);
            validMatches.add(match);
            processedBookIds.add(bookIdStr);

            print(
                "Added book: ${bookDetails.title}, BookId: ${bookIdStr}, MatchId: ${match.matchId}");
          } else {
            print(
                'Skipped book: ${bookDetails.title}, Trade Status: ${bookDetails.isTrade}, Duplicate or Rejected. BookId: ${bookIdStr}');
          }
        }

// Debugging step: Check for duplicates after processing
        print('Processed Book IDs: $processedBookIds');
        print('Fetched Books Count: ${fetchedMatchedBooks.length}');
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
                      if (index >= matchedBooks.length ||
                          index >= validMatches.length) {
                        return Container();
                      }
                      final book = matchedBooks[index];
                      final match = validMatches[index];
                      DateTime now = DateTime.now();
                      DateTime matchedTime = match.matchTime;
                      Duration timeLeft =
                          matchedTime.add(Duration(days: 7)).difference(now);

                      String timeLeftString = '';
                      if (timeLeft.isNegative) {
                        timeLeftString = "Expired";
                        rejectMatch(match.matchId, book.bookId,
                            widget.userId); // Auto-reject if expired
                      } else {
                        int days = timeLeft.inDays;
                        int hours = timeLeft.inHours % 24;
                        timeLeftString = "$days days, $hours hours left";
                      }

                      //print(match.matchId);
                      //print(book.bookId);
                      //print(widget.userId);

                      return Dismissible(
                          key: Key(match.matchId.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            color: Colors.red,
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            await showRejectConfirmation(
                                match.matchId, book.bookId, widget.userId);
                            return false;
                          },
                          child: Column(
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
                                  trailing: Text(
                                    timeLeftString,
                                    style: TextStyle(
                                        color: timeLeft.isNegative
                                            ? Colors.red
                                            : Colors.black),
                                  ),
                                ),
                              ),
                              const Divider()
                            ],
                          ));
                    },
                  ),
                ),
    );
  }
}
