import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryPage extends StatefulWidget {
  final int userId;
  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<History>> fetchHistories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/history/${widget.userId}'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)['histories'];
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
      ),
      body: FutureBuilder<List<History>>(
        future: fetchHistories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No history found'));
          } else {
            final histories = snapshot.data!;
            return ListView.builder(
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final history = histories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildImageContainer(history.userBookPicture),
                      _buildTextContainer(history.userBookName),
                      const Icon(Icons.swap_horiz),
                      _buildTextContainer(history.matchedUserBookName),
                      _buildImageContainer(history.matchedUserBookPicture),
                    ],
                  ),
                );
              },
            );
          }
        },
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
  final String matchedUserBookName;
  final String matchedUserBookPicture;
  final String tradeTime;
  final String userBookName;
  final String userBookPicture;

  History({
    required this.matchedUserBookName,
    required this.matchedUserBookPicture,
    required this.tradeTime,
    required this.userBookName,
    required this.userBookPicture,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      matchedUserBookName: json['matched_user_book_name'],
      matchedUserBookPicture: json['matched_user_book_picture'],
      tradeTime: json['trade_time'],
      userBookName: json['user_book_name'],
      userBookPicture: json['user_book_picture'],
    );
  }
}
