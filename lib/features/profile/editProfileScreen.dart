import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:readee_app/features/profile/widget/constant.dart';
//dropdown
import 'package:flutter/src/material/dropdown.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<EditProfileScreen> {
  bool isEditing = false;
  String firstName = 'Mark';
  String lastName = 'Lee';
  String username = 'onyourmark';
  String email = 'mockup@gmail.com';
  String gender = 'male';

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    usernameController.text = username;
    emailController.text = email;
    genderController.text = gender;
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveProfile() {
    setState(() {
      firstName = firstNameController.text;
      lastName = lastNameController.text;
      username = usernameController.text;
      email = emailController.text;
      gender = genderController.text;
      isEditing = false;
    });
  }

  void cancelEdit() {
    setState(() {
      firstNameController.text = firstName;
      lastNameController.text = lastName;
      usernameController.text = username;
      emailController.text = email;
      genderController.text = gender;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LineAwesomeIcons.arrow_left), // Use const
        ),
        title: const Text('Edit Profile',
            style: TextStyle(fontSize: 20)), // Use const
        actions: isEditing
            ? null
            : [
                IconButton(
                  onPressed: toggleEdit,
                  icon: const Icon(
                      LineAwesomeIcons.alternate_pencil), // Use const
                ),
              ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Use const
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10), // Use const
                  const Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(
                          'https://content.api.news/v3/images/bin/76239ca855744661be0454d51f9b9fa2?width=1024'), // Use const
                    ),
                  ),
                  const SizedBox(height: 40), // Use const

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
                                subtitle: Text(firstName),
                              ),
                      ),

                      const SizedBox(width: 20), // Use const

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
                                subtitle: Text(lastName),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10), // Space between rows

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
                            subtitle: Text(username),
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
                            subtitle: Text(email),
                          ),
                  ),

                  const SizedBox(height: 10), // Space between rows

                  Flexible(
                    child: isEditing
                        ? DropdownButtonFormField<String>(
                            value: genderController.text.isNotEmpty &&
                                    ['Male', 'Female', 'Other']
                                        .contains(genderController.text)
                                ? genderController.text
                                : null, // Set to null if value is not valid
                            decoration: const InputDecoration(
                              labelText: tGender,
                              contentPadding: EdgeInsets.only(bottom: 3),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                genderController.text =
                                    newValue!; // Update the selected value
                              });
                            },
                            items: <String>[
                              'Male',
                              'Female',
                              'Other'
                            ] // Dropdown options
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )
                        : ListTile(
                            title: const Text(tGender),
                            subtitle: Text(gender),
                          ),
                  ),

                  const SizedBox(height: 10), // Use const

                  if (isEditing) ...[
                    ElevatedButton(
                      onPressed: saveProfile,
                      child: const Text('Save'),
                    ),
                    ElevatedButton(
                      onPressed: cancelEdit,
                      child: const Text('Cancel'),
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
