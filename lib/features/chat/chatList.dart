import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readee_app/features/chat/chat.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';

class ChatListPage extends StatelessWidget {
  final int userId;

  const ChatListPage({Key? key, required this.userId}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchChats() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/getAllChat/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('rooms') && data['rooms'] is List) {
        List<Map<String, dynamic>> chats =
            List<Map<String, dynamic>>.from(data['rooms']);

        // Fetch names for each chat based on SenderId/ReceiverId
        for (var chat in chats) {
        final otherUserId = (chat['SenderId'] == userId) ? chat['ReceiverId'] : chat['SenderId'];
        final userDetails = await fetchUserDetails(otherUserId);
        chat['otherUserName'] = userDetails['Username'];
        chat['otherUserRating'] = await fetchUserRating(otherUserId);
        chat['otherUserProfileUrl'] = userDetails['ProfileUrl'];
      }

        return chats;
      } else {
        throw Exception('Unexpected JSON structure');
      }
    } else {
      throw Exception('Failed to load chats');
    }
  }

  Future<Map<String, String>> fetchUserDetails(int userId) async {
  final response = await http.get(Uri.parse('http://localhost:3000/users/$userId'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return {
      'Username': data['Username'] ?? 'Unknown',
      'ProfileUrl': data['ProfileUrl'] ?? '', // Assuming ProfileUrl is a field in the response
    };
  } else {
    throw Exception('Failed to load user details');
  }
}

  Future<String> fetchUserRating(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/getAverageRate/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        double rating =
            data['averageScore']?.toDouble() ?? 0.0; // Parse rating as double
        return rating.toStringAsFixed(2); // Format to two decimal places
      } else {
        // Return a default message if the user does not have a rating
        return 'This user have no rating right now';
      }
    } catch (e) {
      // Handle any other errors (network issues, etc.)
      return 'No rating available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Chat'),
        backgroundColor: Color.fromARGB(255, 228, 248, 255),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chats available'));
          } else {
            final chats = snapshot.data!;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                  backgroundImage: chat['otherUserProfileUrl'] != ''
                      ? NetworkImage(chat['otherUserProfileUrl']) 
                      : null,
                  child: chat['otherUserProfileUrl'] == ''
                      ? Text(chat['otherUserName'].toString().substring(0, 1).toUpperCase())
                      : null,
                ),
                  title: Text(chat['otherUserName']),
                  subtitle: Text('Rating: ${chat['otherUserRating']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        page: ChatPage(
                          userId: userId,
                          roomId: chat['RoomId'],
                          otherName: chat['otherUserName'], otherPorfile: chat['otherUserProfileUrl'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
