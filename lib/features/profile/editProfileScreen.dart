import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:readee_app/features/profile/widget/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String gender;
  final int userID;
  final String profile;

  const EditProfileScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.gender,
    required this.userID,
    required this.profile,
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
  late TextEditingController profileUrlController;

  // Local variables to hold the editable values
  late String editableFirstName;
  late String editableLastName;
  late String editableUsername;
  late String editableEmail;
  late String editableGender;
  late String editableProfileUrl;
  late String profileUrl;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController(text: widget.firstName);
    lastNameController = TextEditingController(text: widget.lastName);
    usernameController = TextEditingController(text: widget.username);
    emailController = TextEditingController(text: widget.email);
    genderController = TextEditingController(text: widget.gender);
    profileUrlController = TextEditingController(text: widget.profile);

    editableFirstName = widget.firstName;
    editableLastName = widget.lastName;
    editableUsername = widget.username;
    editableEmail = widget.email;
    editableGender = widget.gender;
    editableProfileUrl = widget.profile;
  }

  void pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        _imageFile = selectedImage;
        editableProfileUrl = selectedImage.path;
      });
    }
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> updateProfile() async {
    final url = Uri.parse("http://localhost:3000/user/edit/${widget.userID}");

    try {
      final request = http.MultipartRequest("PATCH", url);
      request.headers["Authorization"] = "Bearer <Your-Token>"; // ใส่โทเค็นจริง
      request.fields['email'] = emailController.text;
      request.fields['username'] = usernameController.text;
      request.fields['phone_number'] = "0912345678";
      request.fields['firstname'] = firstNameController.text;
      request.fields['lastname'] = lastNameController.text;
      request.fields['gender'] = editableGender;

      if (_imageFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('profile_url', _imageFile!.path));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        print("Profile updated successfully");
        setState(() {
          editableFirstName = firstNameController.text ?? '';
          editableLastName = lastNameController.text ?? '';
          editableUsername = usernameController.text ?? '';
          editableEmail = emailController.text ?? '';
          editableGender = genderController.text ?? '';
          editableProfileUrl =
              _imageFile != null ? _imageFile!.path : editableProfileUrl;
        });
      } else {
        print("Failed to update profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void saveProfile() {
    setState(() {
      editableFirstName = firstNameController.text;
      editableLastName = lastNameController.text;
      editableUsername = usernameController.text;
      editableEmail = emailController.text;
      editableGender = genderController.text;
      editableProfileUrl =
          _imageFile != null ? _imageFile!.path : editableProfileUrl;
      isEditing = false;
    });

    updateProfile().then((_) {
      fetchUpdatedProfile();
    });
  }

  Future<void> fetchUpdatedProfile() async {
    final url = Uri.parse("http://localhost:3000/users/${widget.userID}");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          // อัปเดตข้อมูลใหม่ใน UI โดยเช็คค่า null ก่อน
          editableFirstName = data["firstname"] ?? '';
          editableLastName = data["lastname"] ?? '';
          editableUsername = data["username"] ?? '';
          editableEmail = data["email"] ?? '';
          editableGender = data["gender"] ?? '';
          editableProfileUrl = data["profile_url"] ?? '';
        });
      } else {
        print("Failed to fetch updated profile: ${response.body}");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  void cancelEdit() {
    setState(() {
      firstNameController.text = widget.firstName;
      lastNameController.text = widget.lastName;
      usernameController.text = widget.username;
      emailController.text = widget.email;
      genderController.text = widget.gender;
      editableProfileUrl = widget.profile;
      _imageFile = null; // รีเซ็ตภาพ
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
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: _imageFile != null
                              ? FileImage(File(_imageFile!.path))
                              : NetworkImage(editableProfileUrl)
                                  as ImageProvider,
                        ),
                        // แสดงไอคอนกล้องเฉพาะเมื่ออยู่ในโหมดแก้ไข
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.blue),
                              onPressed: pickImage, // เรียกใช้ฟังก์ชันเลือกภาพ
                            ),
                          ),
                      ],
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
