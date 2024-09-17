import 'package:flutter/material.dart';
import 'package:readee_app/features/match/widgets/swipe_card.dart';

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
      body: const Center(child: SwipeCard()),
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
