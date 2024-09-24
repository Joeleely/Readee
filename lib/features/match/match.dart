import 'package:flutter/material.dart';
import 'package:readee_app/features/match/widgets/swipe_card.dart';
// import 'package:readee_app/widget/navbar.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: SwipeCard()),
      
    );
  }
}
