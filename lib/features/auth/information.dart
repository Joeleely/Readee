import 'package:flutter/material.dart';
import 'package:readee_app/features/auth/persona.dart';
import 'package:readee_app/features/auth/persona.dart';
import 'package:readee_app/typography.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final _formKey = GlobalKey<FormState>();

  String? _firstname;
  String? _lastname;
  String? _gender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Add the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your basic information',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 34, fontWeight: FontWeight.w600)
              ),
              const SizedBox(height: 10),
              const Text(
                'Please fill your basic account information so that we know who you are',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Firstname label with red asterisk
              RichText(
                text: const TextSpan(
                  text: 'Firstname ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Firstname',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Firstname is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstname = value;
                },
              ),
              const SizedBox(height: 20),
              // Lastname label with red asterisk
              RichText(
                text: const TextSpan(
                  text: 'Lastname ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Lastname',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lastname is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _lastname = value;
                },
              ),
              const SizedBox(height: 20),
              // Phone label without an asterisk
              const Text(
                'Phone',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10, // Limits input to 10 digits
                
              ),
              RichText(
                text: const TextSpan(
                  text: 'Gender ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                items: <String>['Male', 'Female']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  _gender = newValue;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Gender is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PersonaPage(userId: 7,)),
                      );
                      // Handle the next button press when all fields are valid
                      // Proceed with further actions
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
}
