import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:readee_app/features/auth/persona.dart';
import 'package:readee_app/features/chat/chat.dart';
import 'package:readee_app/features/create_book/create_book.dart';
import 'package:readee_app/features/match/pages/match.dart';
import 'package:readee_app/features/match_list/match_list.dart';
import 'package:readee_app/features/profile/profile.dart';
import 'package:readee_app/home.dart';
import 'package:readee_app/pages/logo.dart';

class ReadeeNavigationBar extends StatefulWidget {
  final int userId;
  const ReadeeNavigationBar({super.key, required this.userId});

  @override
  State<ReadeeNavigationBar> createState() => _ReadeeNavigationBarState();
}

class _ReadeeNavigationBarState extends State<ReadeeNavigationBar> {
  int currentTab = 0;
  late List<Widget> screens;
  final PageStorageBucket bucket = PageStorageBucket();
  late Widget currentScreen;

  @override
  void initState() {
    super.initState();
    screens = [
      MatchPage(userID: widget.userId),
      ChatPage(userId: widget.userId,),
      CreateBookPage(userId: widget.userId,),
      ProfilePage(userId: widget.userId,),
      MatchListPage(userId: widget.userId,),
    ];
    currentScreen = MatchPage(userID: widget.userId); // Set the initial screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildNavButton(Icons.swap_horiz, 0, MatchPage(userID: widget.userId,)),
                _buildNavButton(Icons.list, 1, MatchListPage(userId: widget.userId,)),
                FloatingActionButton(
                  elevation: 0,
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(_createRoute(widget.userId));
                  },
                ),
                _buildNavButton(Icons.textsms, 2, ChatPage(userId: widget.userId,)),
                _buildNavButton(Icons.person, 3, ProfilePage(userId: widget.userId,)),
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

Route _createRoute(int userId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => CreateBookPage(userId: userId,),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}


