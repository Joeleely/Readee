import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:readee_app/features/auth/persona.dart';
import 'package:readee_app/typography.dart';

class InformationPage extends StatefulWidget {
  final int userId;
  const InformationPage({Key? key, required this.userId}) : super(key: key);

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _firstname;
  String? _lastname;
  String? _phone;
  String? _gender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updateUserData() async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/user/edit/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Firstname': _firstname,
          'Lastname': _lastname,
          'PhoneNumber': _phone,
          'Gender': _gender,
        }),
      );
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PersonaPage(userId: widget.userId)),
        );
      } else {
        throw Exception('Failed to update user data');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your basic information',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 34,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please fill your basic account information so that we know who you are',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Firstname',
                      initialValue: _firstname,
                      onSaved: (value) => _firstname = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Firstname is required'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Lastname',
                      initialValue: _lastname,
                      onSaved: (value) => _lastname = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Lastname is required'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Phone',
                      initialValue: _phone,
                      onSaved: (value) => _phone = value,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      showAsterisk: false,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter
                            .digitsOnly, // Restrict input to digits only
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      label: 'Gender',
                      value: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      validator: (value) =>
                          value == null ? 'Gender is required' : null,
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            _updateUserData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF28A9D1),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool showAsterisk = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: showAsterisk
                ? const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red))
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: label,
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
          ),
          onSaved: onSaved,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: const [
              TextSpan(text: '*', style: TextStyle(color: Colors.red))
            ],
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          items: <String>['Male', 'Female', 'Other'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
