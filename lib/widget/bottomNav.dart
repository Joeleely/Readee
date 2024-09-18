import 'package:flutter/material.dart';

class ReadeeNavigationBar extends StatefulWidget {
  const ReadeeNavigationBar({super.key});

  @override
  State<ReadeeNavigationBar> createState() => _ReadeeNavigationBarState();
}

class _ReadeeNavigationBarState extends State<ReadeeNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.grey,
      items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.bookmark_add),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.format_list_bulleted),
        label: '',
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.add_circle), // Use add_circle for a more visually similar icon
          label: '',
        ),
      BottomNavigationBarItem(
        icon: Icon(Icons.textsms),
        label: ''
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: ''
      ),
    ],
    );
  }
}
