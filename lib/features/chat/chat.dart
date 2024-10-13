import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final int userId;
  const ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('chat page')),
    );
  }
}
