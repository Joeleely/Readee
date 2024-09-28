import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readee_app/features/profile/profile.dart';
import 'package:readee_app/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 140, 226, 255)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      home: HomePage(),
    );
  }
}
