import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final int userId;
  final int roomId;
  final String otherName;
  final String otherPorfile;

  const ChatPage(
      {super.key,
      required this.userId,
      required this.roomId,
      required this.otherName,
      required this.otherPorfile});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3000/getAllMessage/${widget.roomId}'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages = data.map((message) {
            return {
              'senderId': message['SenderId'] ?? 0,
              'message': message['Message'] ?? 'NotHaveData',
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      // Improved error handling
      _showError('Failed to load messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      final messageData = {
        'SenderId': widget.userId,
        'RoomId': widget.roomId,
        'Message': _controller.text.trim(),
      };

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/createMessage'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(messageData),
        );

        if (response.statusCode == 201) {
          // Parse the response to get the created message
          final newMessage = json.decode(response.body);

          setState(() {
            // Ensure that you check for null values and handle them
            _messages.add({
              'senderId': newMessage['SenderId'],
              'message': newMessage['Message'] ??
                  'ThisShouldNotNull', // Use empty string if null
            });
          });

          _controller.clear();
        } else {
          throw Exception('Failed to send message');
        }
      } catch (e) {
        print('Error sending message: $e'); // Handle errors gracefully
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.otherName}'),
        backgroundColor: const Color.fromARGB(255, 223, 246, 253),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isSentByMe = message['senderId'] == widget.userId;

                  return Row(
                    mainAxisAlignment: isSentByMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isSentByMe)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 3.0),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(widget.otherPorfile),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        alignment: isSentByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSentByMe
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['message'] ?? "Null",
                            style: TextStyle(
                              color: isSentByMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 223, 246, 253),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0, top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                20.0), // Keep the same radius for consistency
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
