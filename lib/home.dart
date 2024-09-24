import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readee_app/features/profile/editProfileScreen.dart';
import 'package:readee_app/features/profile/profile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 140, 226, 255)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      home: const EditProfileScreen(),
    );
  }
}