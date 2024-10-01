import 'package:flutter/material.dart';
import 'package:readee_app/features/profile/editProfileScreen.dart';
import 'package:readee_app/features/profile/review/reviewMain.dart';
import 'package:readee_app/widget/profile_menu.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'username',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'email',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),

                const SizedBox(height: 15),
                const Divider(
                  color: Colors.grey,
                  height: 20,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                const SizedBox(height: 10),
                // Profile details
                ProfileMenuWidget(
                    title: 'Profile',
                    icon: Icons.person,
                    onClicked: () => Get.to(() => const EditProfileScreen()),),
                ProfileMenuWidget(
                    title: 'Genres', icon: Icons.book, onClicked: () {}),
                ProfileMenuWidget(
                    title: 'Reviews', icon: Icons.star, onClicked: () => Get.to(() => const ReviewMainPage()),),
                ProfileMenuWidget(
                    title: 'My Books', icon: Icons.menu_book, onClicked: () {}),
                ProfileMenuWidget(
                    title: 'History', icon: Icons.history, onClicked: () {}),
                const SizedBox(height: 15),
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
    );
  }
}

