import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readee_app/features/auth/resetPassword.dart';
import 'dart:convert';

import 'package:readee_app/widget/flutter2FAMySelf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;
  bool _isSubmitting = false;

  Future<void> requestPasswordReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // HTTP POST request to fetch user info by email
      final response = await http.post(
        Uri.parse('https://readee-api.stthi.com/getUserInfoByEmail'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract user information
        final userId = data['user_id'];
        final username = data['username'];
        final secKey = data['seckey'];

        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('secKey', secKey);

        bool verified = false;
        try {
          FutureBuilder<void>(
            future: Flutter2FAMySelf().verify(
              context: context,
              page: ResetPasswordPage(userId: userId),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                verified = true; // Verification succeeded
                Navigator.pop(context); // Close the dialog
              }
              return Center(
                child: snapshot.connectionState != ConnectionState.done
                    ? Container()
                    : const SizedBox.shrink(),
              );
            },
          );
        } catch (e) {
          print('2FA Verification failed: $e');
          return; // Stop execution if verification fails
        }
        if (!verified) {
          print('2FA Verification canceled or failed.');
          return; // Stop execution if canceled or not verified
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'No user found with this email.';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch user data. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 228, 248, 255),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Forgot your password?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your email address then verify your account to reset your password',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              const Text('Email Address'),
              const SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'hello@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSubmitting ? null : requestPasswordReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28A9D1),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
