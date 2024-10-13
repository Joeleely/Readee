import 'package:flutter/material.dart';
import 'package:readee_app/features/auth/persona.dart';
import 'package:readee_app/features/create_book/create_book.dart';
import 'package:readee_app/features/match/pages/match.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/features/profile/profile.dart';
import 'package:readee_app/widget/bottomNav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 140, 226, 255)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      home: const ReadeeNavigationBar(),
    );
  }
}