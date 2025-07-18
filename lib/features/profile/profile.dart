import 'package:flutter/material.dart';
import 'package:readee_app/features/auth/login.dart';
import 'package:readee_app/features/profile/editGenres.dart';
import 'package:readee_app/features/profile/editProfileScreen.dart';
import 'package:readee_app/features/profile/history.dart';
import 'package:readee_app/features/profile/myBook.dart';
import 'package:readee_app/features/profile/reportedBook.dart';
import 'package:readee_app/features/profile/review.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';
import 'package:readee_app/widget/profile_menu.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Loading...';
  String email = 'Loading...';
  String firstName = 'Loading...';
  String lastName = 'Loading...';
  String gender = 'Loading...';
  String profile = '';
  late int userID;

  @override
  void initState() {
    super.initState();
    userID = widget.userId;
    fetchUsername(userID);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('user_token'); // Replace 'token' with your actual token key
    await prefs.remove('activate2FA');
    await prefs.remove('secKey');

    print("activate2FA: ${prefs.getBool('activate2FA')}");
    print("Seckey: ${prefs.getString('secKey')}");

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> fetchUsername(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/users/$userId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          username = data['Username'] ?? 'ThisIsNull';
          email = data['Email'] ?? 'ThisIsNull';
          firstName = data['Firstname'] ?? 'ThisIsNull';
          lastName = data['Lastname'] ?? 'ThisIsNull';
          gender = data['Gender'] ?? 'ThisIsNull';
          profile = data['ProfileUrl'] ?? 'NoProfile';
        });
        // print('Profile Url: $profile');
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching username: $error');
      setState(() {
        username = 'Error fetching data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile picture
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors
                          .lightBlueAccent, // Set a default background color
                      backgroundImage: profile.isNotEmpty &&
                              Uri.tryParse(profile)?.hasAbsolutePath == true
                          ? NetworkImage(profile)
                          : null, // Use null if no profile image
                      child: (profile.isEmpty ||
                              !Uri.tryParse(profile)!.hasAbsolutePath == true)
                          ? Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 50, // Font size for the initial
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Text color
                              ),
                            )
                          : null, // No text if the image is valid
                    ),
                  ),

                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      username,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      email,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Divider(
                    color: Colors.grey,
                    height: 20,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
                  const SizedBox(height: 25),
                  // Profile details
                  ProfileMenuWidget(
                      title: 'Profile',
                      icon: Icons.person,
                      onClicked: () => Navigator.push(
                          context,
                          CustomPageRoute(
                            page: EditProfileScreen(
                              userID: userID,
                              profile: profile,
                            ),
                          ))),
                  ProfileMenuWidget(
                      title: 'Genres',
                      icon: Icons.book,
                      onClicked: () => Navigator.push(
                          context,
                          CustomPageRoute(
                              page: EditGenrePage(
                            userID: userID,
                          )))),
                  ProfileMenuWidget(
                      title: 'Reviews',
                      icon: Icons.star,
                      onClicked: () => Navigator.push(
                          context,
                          CustomPageRoute(
                              page: ReviewPage(
                            userID: userID,
                          )))),
                  ProfileMenuWidget(
                      title: 'My Books',
                      icon: Icons.menu_book,
                      onClicked: () => Navigator.push(
                          context,
                          CustomPageRoute(
                              page: MyBooksPage(
                            userId: userID,
                          )))),
                  ProfileMenuWidget(
                      title: 'History',
                      icon: Icons.history,
                      onClicked: () => Navigator.push(
                          context,
                          CustomPageRoute(
                            page: HistoryPage(
                              userId: userID,
                            ),
                          ))),
                  const SizedBox(height: 25),
                  SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: logout,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
