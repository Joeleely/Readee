import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:readee_app/features/auth/login.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';
import 'package:readee_app/widget/flutter2FAMySelf.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Recover2FAPage extends StatefulWidget {
  const Recover2FAPage({super.key});

  @override
  State<Recover2FAPage> createState() => _Recover2FAPageState();
}

class _Recover2FAPageState extends State<Recover2FAPage> {
  final TextEditingController _phraseController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int? userId;

  Future<bool> _checkRecoveryPhrase(String phrase, String email) async {
    const url = "http://localhost:3000/getUserInfoByEmail";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          userId = data['user_id'];
        });
        final PhraseHash = sha256.convert(utf8.encode(phrase!)).toString();
        return data['recover_phrase'] == PhraseHash;
      } else if (response.statusCode == 404) {
        throw Exception("User not found");
      } else {
        throw Exception("Failed to fetch user information");
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  void _recover() async {
    final phrase = _phraseController.text.trim();
    final email = _emailController.text.trim();

    if (phrase.isEmpty || email.isEmpty) {
      setState(() {
        _errorMessage = "Both fields are required.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isValid = await _checkRecoveryPhrase(phrase, email);

    setState(() {
      _isLoading = false;
    });

    if (isValid) {
      await Flutter2FAMySelf().activate(
        context: context,
        appName: 'ReadeeApp',
        email: _emailController.text,
      );
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      String? secKey = localStorage.getString('secKey');
      String? recoverPhrase = localStorage.getString('recoverPhrase');

      final recoverPhraseHash =
          sha256.convert(utf8.encode(recoverPhrase!)).toString();

      final url = Uri.parse('http://localhost:3000/user/edit/$userId');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'SecKey': secKey,
          'RecoverPhrase': recoverPhraseHash,
        }),
      );

      if (response.statusCode == 200) {
        print("User information updated successfully.");
        Navigator.push(context, CustomPageRoute(page: const LoginPage()));
      } else {
        print("Failed to update user information: ${response.body}");
      }
    } else {
      setState(() {
        _errorMessage = "Invalid recovery phrase or email. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recover 2FA"),
        backgroundColor: const Color.fromARGB(255, 228, 248, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your email and recovery phrase:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email",
                hintText: "Enter your email",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phraseController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Recovery Phrase",
                hintText: "Enter your recovery phrase",
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _recover,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text("Recover"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phraseController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
