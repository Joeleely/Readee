import 'package:flutter/material.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class Book {
  const Book(
      {required this.title,
      required this.author,
      required this.description,
      required this.isbn});
  final String title;
  final String author;
  final String description;
  final String isbn;
  
}

class _MatchPageState extends State<MatchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //mock appbar
      appBar: AppBar(
        leading:
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
      ),
      body: const Center(child: BookCard()),
      //mock navbar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outlined),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.account_circle_rounded),
          //   label: '',
          // ),
        ],
      ),
    );
  }
}
