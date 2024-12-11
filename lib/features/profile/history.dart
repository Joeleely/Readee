import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:readee_app/features/profile/submitReview.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';

class HistoryPage extends StatefulWidget {
  final int userId;
  // final int matchedUserId;
  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<History>> fetchHistories() async {
    final response = await http
        .get(Uri.parse('http://localhost:3000/history/${widget.userId}'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          json.decode(response.body)['histories'] ?? [];
      return jsonData.map((json) => History.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load histories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Color.fromARGB(255, 228, 248, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<History>>(
          future: fetchHistories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text("You haven't traded with anyone yet."));
            } else {
              final histories = snapshot.data!;
              return ListView.builder(
                itemCount: histories.length,
                itemBuilder: (context, index) {
                  final history = histories[index];
                  print("history.historyId: ${history.historyId}");
                  print(
                      "history.ownerId: ${history.ownerId}, history.matchedUserId: ${history.matchedUserId}");
                  return InkWell(
                    key: ValueKey(history.historyId),
                    onTap: () {
                      if (history.ownerId == widget.userId) {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: RateAndReviewPage(
                              giverId: widget.userId,
                              receiverId: history.matchedUserId ?? 0,
                              bookName: history.userBookName ?? '',
                              giverBookImage: history.userBookPicture ?? '',
                              matchedBookName:
                                  history.matchedUserBookName ?? '',
                              receiverBookImage:
                                  history.matchedUserBookPicture ?? '',
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: RateAndReviewPage(
                              giverId: history.matchedUserId ?? 0,
                              receiverId: history.ownerId ?? 0,
                              bookName: history.matchedUserBookName ?? '',
                              giverBookImage:
                                  history.matchedUserBookPicture ?? '',
                              matchedBookName: history.userBookName ?? '',
                              receiverBookImage: history.userBookPicture ?? '',
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          if (history.ownerId == widget.userId) ...[
                            _buildImageContainer(history.userBookPicture ?? ''),
                            _buildTextContainer(history.userBookName ?? ''),
                            const Icon(Icons.swap_horiz),
                            _buildTextContainer(
                                history.matchedUserBookName ?? ''),
                            _buildImageContainer(
                                history.matchedUserBookPicture ?? ''),
                          ] else ...[
                            _buildImageContainer(
                                history.matchedUserBookPicture ?? ''),
                            _buildTextContainer(
                                history.matchedUserBookName ?? ''),
                            const Icon(Icons.swap_horiz),
                            _buildTextContainer(history.userBookName ?? ''),
                            _buildImageContainer(history.userBookPicture ?? ''),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildImageContainer(String imageUrl) {
    return Container(
      width: 60,
      height: 60,
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

  Widget _buildTextContainer(String text) {
    return Container(
      alignment: Alignment.center,
      width: 80,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class History {
  final int? historyId;
  final String? matchedUserBookName;
  final String? matchedUserBookPicture;
  final String? tradeTime;
  final String? userBookName;
  final String? userBookPicture;
  final int? ownerId; // Make nullable if userId might be null
  final int? matchedUserId; // Make nullable if matchedUserId might be null

  History({
    required this.historyId,
    required this.matchedUserBookName,
    required this.matchedUserBookPicture,
    required this.tradeTime,
    required this.userBookName,
    required this.userBookPicture,
    this.ownerId, // Nullable field
    this.matchedUserId, // Nullable field
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      historyId: json['history_id'] as int?,
      matchedUserBookName: json['matched_user_book_name'] as String?,
      matchedUserBookPicture: json['matched_user_book_picture'] as String?,
      tradeTime: json['trade_time'] as String?,
      userBookName: json['user_book_name'] as String?,
      userBookPicture: json['user_book_picture'] as String?,
      ownerId: json['owner_id'] as int?, // Default to 0 if null
      matchedUserId: json['matched_user_id'] as int?, // Default to 0 if null
    );
  }
}
