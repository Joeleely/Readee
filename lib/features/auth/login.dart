import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:readee_app/features/auth/information.dart';
import 'package:readee_app/features/auth/persona.dart';
import 'package:readee_app/features/auth/register.dart';
import 'package:readee_app/widget/bottomNav.dart';
import 'package:readee_app/widget/flutter2FAMySelf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'), // Adjust the URL if needed
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "emailOrUsername": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['userId'];
        final firstName = data['firstname'];
        final secKey = data['secKey'];

        if (secKey == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Failed to login! Please make sure you have an account")),
          );
          return; // Stop execution if `secKey` is null
        }

        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setBool('activate2FA', true);
        localStorage.setString('secKey', secKey);

        //print("activate2FA: ${localStorage.getBool('activate2FA')}");
        //print("Seckey: $secKey");

        // Perform 2FA verification
        bool verified = false;
        try {
          FutureBuilder<void>(
            future: Flutter2FAMySelf().verify(
              context: context,
              page: ReadeeNavigationBar(userId: userId,
                        initialTab: 0,),
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

        // Store token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);

        if (firstName == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => InformationPage(userId: userId)),
          );
        } else {
          // Check user genres
          final genresResponse = await http
              .get(Uri.parse('http://localhost:3000/userGenres/$userId'));

          if (genresResponse.statusCode == 404) {
            // If genres not found, navigate to PersonaPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => PersonaPage(userId: userId)),
            );
          } else if (genresResponse.statusCode == 200) {
            // Navigate to the main navigation page if genres are found
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ReadeeNavigationBar(
                        userId: userId,
                        initialTab: 0,
                      )),
            );
          } else {
            // Handle other possible errors (e.g., server error)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error checking user genres')),
            );
          }
        }
        setState(() {
          _errorMessage = null; // Clear error message on successful login
        });
      } else {
        setState(() {
          _errorMessage = 'Username or password incorrect';
        });
      }
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Readee!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Please enter your details.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 50),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email/Username'),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'hello@email.com',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  ),
                ),
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password'),
                ),
                const SizedBox(height: 5),
                PasswordFormField(controller: _passwordController),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      print('Forgot password? tapped');
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: login, // Calls the login function
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF28A9D1),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 40),
                // const Row(
                //   children: [
                //     Expanded(
                //       child: Divider(
                //         color: Colors.grey,
                //         height: 1,
                //       ),
                //     ),
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 8.0),
                //       child: Text('or login with'),
                //     ),
                //     Expanded(
                //       child: Divider(
                //         color: Colors.grey,
                //         height: 1,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 40),
                // ElevatedButton.icon(
                //   onPressed: () async {
                //     await loginWithGoogle();
                //   },
                //   icon: const Image(
                //     image: AssetImage('assets/Google_logo.png'),
                //     width: 24,
                //     height: 24,
                //   ),
                //   label: const Text('Google'),
                //   style: ElevatedButton.styleFrom(
                //     foregroundColor: Colors.black,
                //     backgroundColor: Colors.white,
                //     side: const BorderSide(color: Colors.grey),
                //     minimumSize: const Size(double.infinity, 48),
                //   ),
                // ),
                // const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      text: "You don't have an account? ",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RegisterPage()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordFormField({Key? key, required this.controller})
      : super(key: key);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: '********',
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
