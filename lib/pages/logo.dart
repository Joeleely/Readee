import 'package:flutter/material.dart';
import 'package:readee_app/features/auth/login.dart';

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(      
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Replace this with your logo
            const Image(image: AssetImage('assets/logo.png')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
