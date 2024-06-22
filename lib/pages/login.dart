import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {

    //final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 140, 226, 255)
      ),
      body: const Center(
        child: Text('This is the login page.'),
      ),
    );
  }
}