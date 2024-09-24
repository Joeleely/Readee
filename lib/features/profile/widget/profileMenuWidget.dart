import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onClicked,
    this.endIcon = false,
    this.color,
  });

  final String title;
  final IconData icon;
  final VoidCallback onClicked;
  final bool endIcon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: onClicked,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Icon(
            //icon profile
            icon,
            color: Colors.black,
            size: 30,
          ),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
            )));
  }
}

