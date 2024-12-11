import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:io';

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
  final ScrollController _scrollController = ScrollController();
  late WebSocketChannel _channel;
  final ImagePicker _picker = ImagePicker();
  bool _isWebSocketConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _fetchMessages();
  }

  void _connectToWebSocket() {
    print("Attempting WebSocket connection...");
    if (_isWebSocketConnected) {
      print("WebSocket already connected. Skipping...");
      return;
    }
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:3000/chat/${widget.roomId}'),
      );

      _isWebSocketConnected = true;

      print('WebSocket connection established');
      _channel.stream.listen(
        (data) {
          print("Received data: $data");
          try {
            final message = json.decode(data);
            print("Decoded message: $message");
            if (message['SenderId'] != null && message['Message'] != null) {
              // Prevent duplicates if already in the list
              final isDuplicate = _messages.any((m) =>
                  m['senderId'] == message['SenderId'] &&
                  m['message'] == message['Message']);

              if (!isDuplicate) {
                setState(() {
                  _messages.add({
                    'senderId': message['SenderId'],
                    'message': message['Message'],
                    'imageUrl': message['ImageUrl'] ?? '',
                  });
                });
                _scrollToBottom();
              }
            }
          } catch (e) {
            print("Error decoding message: $e");
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _showError("WebSocket connection error: $error");
        },
        onDone: () {
          print('WebSocket connection closed');
          _isWebSocketConnected = false; // Allow reconnection if closed
        },
      );
    } catch (e) {
      _showError("Failed to connect to WebSocket: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.microtask(() {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      print("ScrollController has no clients.");
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getAllMessage/${widget.roomId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages = data.map((message) {
            return {
              'senderId': message['SenderId'] ?? 0,
              'message': message['Message'] ?? '',
              'imageUrl': message['ImageUrl'] ?? '',
            };
          }).toList();
        });
        _scrollToBottom();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      _showError('Failed to load messages: $e');
    }
  }

  Future<void> _pickAndSendImage() async {
    // Open the image picker
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    print('Image selected: ${image.path}');

    // Create a request to upload the image
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/uploadImage'), // Backend API endpoint
    );

    request.files.add(
      await http.MultipartFile.fromPath(
          'file', image.path), // Attach the image file
    );

    try {
      // Send the request
      final response = await request.send();
      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decode the response to get the image URL
        final responseData = await response.stream.bytesToString();
        final responseJson = json.decode(responseData);

        // Get the image URL from the response
        final imageUrl = responseJson['url'];
        print(imageUrl);

        print("Image uploaded successfully: $imageUrl");

        // If URL is returned, call _sendMessage to send the image URL as a message
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _sendMessage(
              imageUrl: imageUrl); // Ensure the imageUrl is passed here
        } else {
          _showError('No image URL returned from backend');
        }
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      _showError('Failed to upload image: $e');
    }
  }

  Future<void> _sendMessage({String? text, String? imageUrl}) async {
    if (text == null && imageUrl == null)
      return; // Don't proceed if both are null

    final messageData = {
      'SenderId': widget.userId,
      'RoomId': widget.roomId,
      'Message': text, // Text message (can be null if only image is sent)
      'ImageUrl': imageUrl, // Image URL
    };

    try {
      if (_channel != null) {
        _channel.sink.add(json.encode(messageData)); // Send the message
        print('Message sent through WebSocket: $messageData');

        _scrollToBottom(); // Scroll to the latest message

        // Trigger a single rebuild for the new message
        setState(() {
          _controller.clear(); // Clear the input field
        });
      } else {
        print('WebSocket is not connected.');
      }
    } catch (e) {
      print('Error sending WebSocket message: $e');
      _showError('Error sending message: $e');
    }

    // try {
    //   final response = await http.post(
    //     Uri.parse(
    //         'http://localhost:3000/createMessage'), // Backend API endpoint
    //     headers: {'Content-Type': 'application/json'},
    //     body: json.encode(messageData), // JSON-encoded body
    //   );

    //   if (response.statusCode == 201) {
    //     _controller.clear(); // Clear the text field (if applicable)
    //     print('Message sent successfully');
    //   } else {
    //     throw Exception('Failed to send message');
    //   }
    // } catch (e) {
    //   _showError('Error sending message: $e');
    // }
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
  void dispose() {
    _channel.sink.close();
    _isWebSocketConnected = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.otherName}'),
        backgroundColor: const Color.fromARGB(255, 223, 246, 253),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(5),
            ),
            width: double.infinity,
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
                const SizedBox(width: 3),
                Text(
                  'Make sure to confirm all details before finalizing the swap.',
                  style: TextStyle(
                      fontSize: 12, color: Colors.black.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSentByMe = message['senderId'] == widget.userId;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isSentByMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isSentByMe)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 3.0, top: 7.0),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(widget.otherPorfile),
                        ),
                      ),
                    // This Container will hold the message and the image
                    Expanded(
                      child: Container(
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
                          child: message['imageUrl'] != null &&
                                  message['imageUrl'].isNotEmpty
                              ? Image.network(
                                  message['imageUrl'],
                                  errorBuilder: (context, error, stackTrace) {
                                    print("error in image: $error");
                                    print(message['imageUrl']);
                                    return Text(
                                      "{Failed to load image}",
                                      style: TextStyle(
                                        color: isSentByMe
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    );
                                  },
                                )
                              : Text(
                                  message['message'] ?? "Null",
                                  style: TextStyle(
                                    color: isSentByMe
                                        ? Colors.white
                                        : Colors.black,
                                  ),
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image),
                    onPressed: _pickAndSendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () =>
                        _sendMessage(text: _controller.text.trim()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
