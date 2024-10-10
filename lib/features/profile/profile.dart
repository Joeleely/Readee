import 'package:flutter/material.dart';
import 'package:readee_app/features/profile/editGenres.dart';
import 'package:readee_app/features/profile/editProfileScreen.dart';
import 'package:readee_app/features/profile/widget/pageRoute.dart';
import 'package:readee_app/features/profile/review/reviewMain.dart';
import 'package:readee_app/widget/profile_menu.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
  String firstName = '';
  String lastName = '';
  String gender = '';
  final int userID = 2;

  @override
  void initState() {
    super.initState();
    fetchUsername(userID);
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
        });
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
      body: Expanded(
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
                  const Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(
                          'https://content.api.news/v3/images/bin/76239ca855744661be0454d51f9b9fa2?width=1024'),
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
                              firstName: firstName,
                              lastName: lastName,
                              username: username,
                              email: email,
                              gender: gender,
                              userID: userID,
                            ),
                          ))),
                  ProfileMenuWidget(
                      title: 'Genres', icon: Icons.book, onClicked: () => Navigator.push(
                          context,
                          CustomPageRoute(
                            page: EditGenrePage(userID: userID,)
                          ))),
                  ProfileMenuWidget(
                      title: 'Reviews', icon: Icons.star, onClicked: () {}),
                  ProfileMenuWidget(
                      title: 'My Books',
                      icon: Icons.menu_book,
                      onClicked: () {}),
                  ProfileMenuWidget(
                      title: 'History', icon: Icons.history, onClicked: () {}),
                  const SizedBox(height: 25),
                  SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () {},
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
