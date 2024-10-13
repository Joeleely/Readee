import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:readee_app/features/create_book/edit_book.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';
import 'package:readee_app/typography.dart';

class BookDetailPage extends StatefulWidget {
  final int userId;
  final int bookId;
  final int matchId;
  final bool isEdit;

  BookDetailPage(
      {required this.bookId, required this.userId, required this.matchId, required this.isEdit});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Book2 book;
  late String userName;
  late String ownerName = '';
  late int timesSwap = 0;
  late double rating = 0.0;
  late String profile = '';
  bool isExpanded = false;
  bool showToggle = false;
  bool isLoading = true;
  String tradeRequestStatus = '';
  bool showAcceptAndRejectButton = false;
  int personSwap = 0;
  int firstUserId = 0;
  int secondUserId = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchBookData();
    if (widget.matchId != 0) _checkTradeRequestStatus();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/users/${widget.userId}'));

      //print("This is matchID: ${widget.matchId}");
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          userName = userData['Username'] ?? 'ThisIsNull';
          timesSwap = userData['timesSwap'] ?? 0;
          rating = userData['rating'] ?? 0.0;
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
      final response = await http
          .get(Uri.parse('http://localhost:3000/getBook/${widget.bookId}'));

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
            bookId: bookData['BookId']?.toString() ?? 'ThisIsNull',
          );
          _fetchOwnerData(book.ownerId); // Fetch owner’s data here
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

  Future<void> _fetchOwnerData(String ownerId) async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/users/$ownerId'));

      if (response.statusCode == 200) {
        final ownerData = json.decode(response.body);
        setState(() {
          ownerName = ownerData['Username'] ?? 'ThisIsNull';
        });
      } else {
        _logError('Failed to fetch owner data: ${response.statusCode}');
      }
    } catch (e) {
      _logError('Error fetching owner data: $e');
    }
  }

  Future<void> _checkTradeRequestStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getAllMatches/${widget.matchId}'),
      );

      if (response.statusCode == 200) {
        final matchData = json.decode(response.body);
        setState(() {
          tradeRequestStatus = matchData['TradeRequestStatus'] ?? '';
          firstUserId = matchData['MatchedUserId'];
          secondUserId = matchData['OwnerId'];
          dynamic requestInitiatorId = matchData['RequestInitiatorId'];

          if (requestInitiatorId != null) {
            if (firstUserId == requestInitiatorId) { //secondUserId always be sender
              personSwap = secondUserId;
              secondUserId = firstUserId;
              firstUserId = personSwap;
            }
            if (widget.userId == firstUserId) { //firstUserId is the receiver
              showAcceptAndRejectButton = true;
            }
          }
        });
      } else {
        _logError('Failed to fetch match data: ${response.statusCode}');
      }
    } catch (e) {
      _logError('Error fetching match data: $e');
    }
  }

  void _logError(String message) {
    // You can use your preferred logging package or service here
    print(message); // Simple logging
  }

  Uint8List _convertBase64Image(String base64String) {
    String base64Data = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
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

  void _showConfirmationDialog(
      String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showAcceptConfirmationDialog() {
  _showConfirmationDialog(
    'Confirm accept',
    'Are you sure to accept the request?',
    () async {
      final url = Uri.parse(
          'http://localhost:3000/trades/${widget.matchId}/accept');

      try {
        final response = await http.post(url);

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              tradeRequestStatus = 'accepted';
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trade request accepted successfully!')),
          );
        } else {
          _logError('Failed to accept trade request: ${response.statusCode}');
        }
      } catch (e) {
        _logError('Error accepting trade request: $e');
      }
    },
  );
}

  void _showRejectConfirmationDialog() {
  _showConfirmationDialog(
    'Confirm reject',
    'Are you sure to reject the request?',
    () async {
      final url = Uri.parse(
          'http://localhost:3000/trades/${widget.matchId}/reject');

      try {
        final response = await http.post(url);

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              tradeRequestStatus = 'rejected';
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trade request rejected successfully!')),
          );
        } else {
          _logError('Failed to reject trade request: ${response.statusCode}');
        }
      } catch (e) {
        _logError('Error rejecting trade request: $e');
      }
    },
  );
}

  void _showRequestConfirmationDialog() {
    _showConfirmationDialog(
      'Confirm reject',
      'Are you sure to reject the request?',
      () {
        Navigator.of(context).pop();
        _sendTradeRequest();
      },
    );
  }

  Future<void> _sendTradeRequest() async {
    final url = Uri.parse(
        'http://localhost:3000/trades/${widget.matchId}/send-request/${widget.userId}');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          tradeRequestStatus = 'pending';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trade request sent successfully!')),
        );
      } else {
        _logError('Failed to send trade request: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send trade request.')),
        );
      }
    } catch (e) {
      _logError('Error sending trade request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending trade request.')),
      );
    }
  }

  Future<void> _navigateToEditBookPage() async {
    final result = await Navigator.push(context,
        CustomPageRoute(page: EditBookPage(bookId: int.parse(book.bookId))));

    if (result == true) {
      _fetchBookData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    int currentPhoto = 0; // Keep track of the current photo index

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LineAwesomeIcons.arrow_left),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              book.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  "${book.quality}%",
                  style: TypographyText.h4(Colors.white),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (widget.userId == int.parse(book.ownerId) && widget.isEdit == true)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: const Icon(Icons.edit), // Edit icon
                onPressed: () {
                  _navigateToEditBookPage();
                },
              ),
            ),
        ],
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
                          : MemoryImage(
                                  _convertBase64Image(book.img[currentPhoto]))
                              as ImageProvider<Object>,
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
                        Text(ownerName),
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
                    if (widget.userId != int.parse(book.ownerId))
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
          if (widget.userId == secondUserId && tradeRequestStatus == 'pending')
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _showRequestConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: tradeRequestStatus == 'pending'
                        ? Colors.grey
                        : Colors.cyan,
                  ),
                  child: Text(
                    tradeRequestStatus == 'pending'
                        ? 'Already send request'
                        : 'Request to trade',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          if (showAcceptAndRejectButton && tradeRequestStatus == 'pending')
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _showRejectConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Reject request',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    onPressed: _showAcceptConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.cyan,
                    ),
                    child: const Text(
                      'Accept request',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (tradeRequestStatus == 'accepted')
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Trade success',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
      required this.bookId,
      required this.description});
  final String title;
  final String author;
  final List<String> img;
  final String genre;
  final String quality;
  final String description;
  final String ownerId;
  final String bookId;
}
