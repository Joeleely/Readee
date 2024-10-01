import 'package:flutter/material.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/widget/bottomNav.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
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
      
      
    );
  }
}
