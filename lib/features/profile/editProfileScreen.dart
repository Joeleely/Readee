import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:readee_app/features/profile/widget/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String gender;
  final int userID;
  final String prifile;

  const EditProfileScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.gender,
    required this.userID,
    required this.prifile,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isEditing = false;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController genderController;

  // Local variables to hold the editable values
  late String editableFirstName;
  late String editableLastName;
  late String editableUsername;
  late String editableEmail;
  late String editableGender;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController(text: widget.firstName);
    lastNameController = TextEditingController(text: widget.lastName);
    usernameController = TextEditingController(text: widget.username);
    emailController = TextEditingController(text: widget.email);
    genderController = TextEditingController(text: widget.gender);

    editableFirstName = widget.firstName;
    editableLastName = widget.lastName;
    editableUsername = widget.username;
    editableEmail = widget.email;
    editableGender = widget.gender;
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveProfile() {
    setState(() {
      // Update the local variables with the edited values
      editableFirstName = firstNameController.text;
      editableLastName = lastNameController.text;
      editableUsername = usernameController.text;
      editableEmail = emailController.text;
      editableGender = genderController.text;
      isEditing = false;
    });
  }

  void cancelEdit() {
    setState(() {
      firstNameController.text = editableFirstName;
      lastNameController.text = editableLastName;
      usernameController.text = editableUsername;
      emailController.text = editableEmail;
      genderController.text = editableGender;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LineAwesomeIcons.arrow_left),
        ),
        title: const Text('Edit Profile', style: TextStyle(fontSize: 20)),
        actions: isEditing
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                    onPressed: toggleEdit,
                    icon: const Icon(LineAwesomeIcons.alternate_pencil),
                  ),
                ),
              ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(widget.prifile),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // First Name and Last Name in one line
                  Row(
                    children: [
                      Flexible(
                        child: isEditing
                            ? TextField(
                                controller: firstNameController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 3),
                                  labelText: tFirstName,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                              )
                            : ListTile(
                                title: const Text(tFirstName),
                                subtitle: Text(editableFirstName),
                              ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        child: isEditing
                            ? TextField(
                                controller: lastNameController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 3),
                                  labelText: tLastName,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                              )
                            : ListTile(
                                title: const Text(tLastName),
                                subtitle: Text(editableLastName),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Username
                  Flexible(
                    child: isEditing
                        ? TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 3),
                              labelText: tUsername,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                          )
                        : ListTile(
                            title: const Text(tUsername),
                            subtitle: Text(editableUsername),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: isEditing
                        ? TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 3),
                              labelText: tEmail,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                          )
                        : ListTile(
                            title: const Text(tEmail),
                            subtitle: Text(editableEmail),
                          ),
                  ),
                  const SizedBox(height: 10),

                  Flexible(
                    child: isEditing
                        ? DropdownButtonFormField<String>(
                            value: editableGender.isNotEmpty &&
                                    ['Male', 'Female', 'Other']
                                        .contains(editableGender)
                                ? editableGender
                                : null,
                            decoration: const InputDecoration(
                              labelText: tGender,
                              contentPadding: EdgeInsets.only(bottom: 3),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                editableGender = newValue!;
                                genderController.text = newValue;
                              });
                            },
                            items: <String>['Male', 'Female', 'Other']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )
                        : ListTile(
                            title: const Text(tGender),
                            subtitle: Text(editableGender),
                          ),
                  ),
                  const SizedBox(height: 30),
                  if (isEditing) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: saveProfile,
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.cyan)),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        ElevatedButton(
                          onPressed: cancelEdit,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
