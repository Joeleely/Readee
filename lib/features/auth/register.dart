import 'dart:convert';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2fa/flutter_2fa.dart';
import 'package:flutter_2fa/screens/verify_code.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:readee_app/features/auth/information.dart';
import 'package:http/http.dart' as http;
import 'package:readee_app/features/profile/widget/pageRoute.dart';
import 'package:readee_app/widget/flutter2FAMySelf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool agreedToTerms = false;
  String? _usernameError;
  String? _emailError;
  String? secKey;
  String? recoverPhrase;

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@(?:gmail\.com|hotmail\.com)$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _checkUser() async {
    final url = Uri.parse('https://readee-api.stthi.com/checkUser');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "username": _usernameController.text,
      "email": _emailController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 409) {
        final data = jsonDecode(response.body);
        if (data['error'].contains('username')) {
          setState(() {
            _usernameError = data['error'];
          });
        }
        if (data['error'].contains('email')) {
          setState(() {
            _emailError = data['error'];
          });
        }
        return; // Early return if there's an error
      } else {
        // Clear errors if checks pass
        setState(() {
          _usernameError = null;
          _emailError = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking user: $e")),
      );
    }
  }

  Future<void> _register() async {
    // First, check for existing username/email
    await _checkUser();

    if (_usernameError != null || _emailError != null)
      return; // Prevent registration if there are errors

    if (_formKey.currentState?.validate() != true) return;

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setBool('activate2FA', true);

    bool proceed = await showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (context) => AlertDialog(
        title: const Text("Important"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Please securely store your Recovery Phrase. It is essential for recovering your 2FA authentication in case you lose access to your device.",
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue[100]!)),
            child: const Text(
              "Understood",
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), // Return `false` to cancel
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (!proceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Registration process cancelled by the user.")),
      );
      return;
    }

    await Flutter2FAMySelf().activate(
      context: context,
      appName: 'ReadeeApp',
      email: _emailController.text,
    );

    // After activation, check if the 2FA is activated in SharedPreferences
    bool isActivated = localStorage.getBool('activate2FA') ?? false;
    secKey = localStorage.getString('secKey');
    recoverPhrase = localStorage.getString('recoverPhrase');

    //print("This is secKey: $secKey");

    if (!isActivated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please activate 2FA first.")),
      );
      return;
    }

    final recoverPhraseHash =
        sha256.convert(utf8.encode(recoverPhrase!)).toString();

    // Proceed with the registration logic here
    final url = Uri.parse('https://readee-api.stthi.com/createUser');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "username": _usernameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "ProfileUrl":
          "https://img.freepik.com/free-vector/cute-shiba-inu-dog-reading-book-cartoon_138676-2435.jpg",
      "Seckey": secKey,
      "Recoverphrase": recoverPhraseHash,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("Status code: ${response.statusCode}");
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final userId = data['UserId'];
        Navigator.push(
          context,
          CustomPageRoute(page: InformationPage(userId: userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to register: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print("eError: $e");
    }
  }

  InputDecoration _inputDecoration(String hintText, {bool showError = false}) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        borderSide: BorderSide(
          color: showError ? Colors.red : Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create account!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Create your account to get started.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: 'Username can’t change later',
                        child: Icon(
                          Icons.help_outline,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Username'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _usernameController,
                    decoration: _inputDecoration('Enter your username'),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Username is required' : null,
                  ),
                  if (_usernameError != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      _usernameError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: 'Email should use @gmail.com or @hotmail.com',
                        child: Icon(
                          Icons.help_outline,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Email'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('hello@mail.com'),
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return 'Email is required';
                      } else if (!_isValidEmail(value!)) {
                        return 'Invalid email format';
                      }
                      return null; // No error
                    },
                  ),
                  if (_emailError != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      _emailError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Tooltip(
                        message:
                            'Password should contain at least 8 characters',
                        child: Icon(
                          Icons.help_outline,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Password'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  PasswordFormField(
                    controller: _passwordController,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 25),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Confirm Password'),
                  ),
                  const SizedBox(height: 5),
                  PasswordFormField(
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return 'Confirm Password is required';
                      } else if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Row(
                  //   children: [
                  //     Checkbox(
                  //       value: agreedToTerms,
                  //       onChanged: (bool? value) {
                  //         if (value != null) {
                  //           setState(() {
                  //             agreedToTerms = value;
                  //           });
                  //         }
                  //       },
                  //     ),
                  //     Expanded(
                  //       child: RichText(
                  //         text: TextSpan(
                  //           text: 'By registering, you are agreeing with our ',
                  //           children: [
                  //             TextSpan(
                  //               text: 'Terms of Use',
                  //               style: const TextStyle(
                  //                 decoration: TextDecoration.underline,
                  //                 color: Color(0xFF28A9D1),
                  //               ),
                  //               recognizer: TapGestureRecognizer()
                  //                 ..onTap = () {},
                  //             ),
                  //             const TextSpan(text: ' and '),
                  //             TextSpan(
                  //               text: 'Privacy Policy',
                  //               style: const TextStyle(
                  //                 decoration: TextDecoration.underline,
                  //                 color: Color(0xFF28A9D1),
                  //               ),
                  //               recognizer: TapGestureRecognizer()
                  //                 ..onTap = () {},
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF28A9D1),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Sign up'),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const PasswordFormField({Key? key, required this.controller, this.validator})
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
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        } else if (value.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        return null; // No error
      },
    );
  }
}
