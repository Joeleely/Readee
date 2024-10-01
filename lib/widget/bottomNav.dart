import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:readee_app/features/auth/persona.dart';
import 'package:readee_app/features/chat/chat.dart';
import 'package:readee_app/features/match/pages/match.dart';
import 'package:readee_app/features/match_list/match_list.dart';
import 'package:readee_app/features/profile/profile.dart';
import 'package:readee_app/home.dart';
import 'package:readee_app/pages/logo.dart';

class ReadeeNavigationBar extends StatefulWidget {
  const ReadeeNavigationBar({super.key});

  @override
  State<ReadeeNavigationBar> createState() => _ReadeeNavigationBarState();
}

class _ReadeeNavigationBarState extends State<ReadeeNavigationBar> {
  int currentTab = 0;
  final List<Widget> screens = [
    const MatchPage(),
    const ChatPage(),
    const ProfilePage(),
    const MatchListPage(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const LogoPage(); // chage here to home page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildNavButton(Icons.swap_horiz, 0, const MatchPage()), // also change here
                _buildNavButton(Icons.list, 1, const MatchListPage()),
                FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    // Define the action for the floating action button here
                  },
                ),
                _buildNavButton(Icons.textsms, 2, const ChatPage()),
                _buildNavButton(Icons.person, 3, const ProfilePage()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, int tabIndex, Widget page) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentScreen = page;
          currentTab = tabIndex;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: currentTab == tabIndex ? Colors.cyan : Colors.grey,
          ),
        ],
      ),
    );
  }
}
