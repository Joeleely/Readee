import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:readee_app/features/profile/widget/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  final int userID;
  final String profile;

  const EditProfileScreen({super.key, required this.userID, required this.profile});

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
late String editableFirstName = '';
late String editableLastName = '';
late String editableUsername = '';
late String editableEmail = '';
late String editableGender = '';
late String profilePicture = '';

  String? _usernameError;
  String? base64Image;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    genderController = TextEditingController();
    _fetchUserData(); // Fetch user data on initialization
  }

   Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Compress the image
      final compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        minWidth: 500,
        minHeight: 500,
        quality: 25,
      );

      if (compressedImage != null) {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/temp_image.jpg')
          ..writeAsBytesSync(compressedImage);
        final imageTemp = XFile(tempFile.path);

        setState(() {
          _selectedImage = imageTemp;
        });

        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        print('Image compression failed');
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/users/${widget.userID}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          editableFirstName = data['Firstname'] ?? '';
          editableLastName = data['Lastname'] ?? '';
          editableUsername = data['Username'] ?? '';
          editableEmail = data['Email'] ?? '';
          editableGender = data['Gender'] ?? '';
          profilePicture = data['Profile'] ?? '';

          firstNameController.text = editableFirstName;
          lastNameController.text = editableLastName;
          usernameController.text = editableUsername;
          emailController.text = editableEmail;
          genderController.text = editableGender;
        });
      } else {
        print('Failed to load user data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> saveProfile() async {
    // Update the local variables with the edited values
    editableFirstName = firstNameController.text;
    editableLastName = lastNameController.text;
    editableUsername = usernameController.text;
    editableEmail = emailController.text;
    editableGender = genderController.text;

    //await _checkUser(editableUsername, usernameController.text);

    // If there's an error, do not proceed with saving
    // if (_usernameError != null) {
    //   return; // Early return if there's an error
    // }

    // Prepare the data for the POST request
    final Map<String, dynamic> data = {
      'Firstname': editableFirstName,
      'Lastname': editableLastName,
      'Gender': editableGender,
      'ProfileUrl': base64Image,
    };
  //   if (editableUsername != usernameController.text) {
  //   data['Username'] = editableUsername;
  // }

  // setState(() {
  //     _usernameError = null;
  //   });

    // Perform the HTTP POST request
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/user/edit/${widget.userID}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Successfully updated the profile
        print('Profile updated successfully!');
        setState(() {
          isEditing = false; // Exit editing mode
        });
      } else {
        // Handle error response
        print('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while updating profile: $e');
    }
  }

  void cancelEdit() {
    setState(() {
      firstNameController.text = editableFirstName;
      lastNameController.text = editableLastName;
      usernameController.text = editableUsername;
      emailController.text = editableEmail;
      genderController.text = editableGender;
      _usernameError = null;
      isEditing = false;
    });
  }

  // Future<void> _checkUser(String beforeName, String afterName) async {
  //   final url = Uri.parse('http://localhost:3000/checkUser');
  //   final headers = {'Content-Type': 'application/json'};
  //   final body = jsonEncode({
  //     "username": usernameController.text,
  //     "email": emailController.text,
  //   });

  //   if(beforeName == afterName){
  //     setState(() {
  //         _usernameError = null;
  //       });
  //   }

  //   try {
  //     final response = await http.post(url, headers: headers, body: body);
  //     if (response.statusCode == 409) {
  //       final data = jsonDecode(response.body);
  //       if (data['error'].contains('username')) {
  //         setState(() {
  //           _usernameError = data['error'];
  //         });
  //       }
  //       return; // Early return if there's an error
  //     } else {
  //       // Clear errors if checks pass
  //       setState(() {
  //         _usernameError = null;
  //       });
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error checking user: $e")),
  //     );
  //   }
  // }

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
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: _selectedImage != null
                          ? FileImage(File(_selectedImage!.path))
                          : NetworkImage(widget.profile) as ImageProvider,
                      child: _selectedImage == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.white54)
                          : null,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                    child: isEditing
                        ? Container(
                            color: Colors.grey[300],
                            child: ListTile(
                              title: const Text(tUsername),
                              subtitle: Text(editableUsername),
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
                        ? Container(
                            color: Colors.grey[300],
                            child: ListTile(
                              title: const Text(tEmail),
                              subtitle: Text(editableEmail),
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
                ]
          )
        ),
      ),
    ),
      )
    );
  }
}
