import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:readee_app/features/profile/widget/constant.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LineAwesomeIcons.alternate_pencil), // Use const
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
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10), // Use const
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(
                          'https://content.api.news/v3/images/bin/76239ca855744661be0454d51f9b9fa2?width=1024'), // Use const
                    ),
                  ),
                  SizedBox(height: 50), // Use const

                  // First Name and Last Name in one line
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(bottom: 3), // Use const
                            labelText: tFristName,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: tHintWaitingBackend,
                            labelStyle:
                                TextStyle(color: Colors.black), // Use const
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ), // Use const
                          ),
                        ),
                      ),
                      SizedBox(width: 20), // Use const
                      Flexible(
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(bottom: 3), // Use const
                            labelText: 'Lastname',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: 'waiting backend',
                            labelStyle:
                                TextStyle(color: Colors.black), // Use const
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ), // Use const
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20), // Space between rows

                  // Username
                  TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: 'Username',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'waiting backend',
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: 'Email',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'waiting backend',
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 20), // Space between rows
                  TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: 'Gender',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'waiting backend',
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
