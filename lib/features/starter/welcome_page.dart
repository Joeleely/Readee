import 'dart:math';

import 'package:flutter/material.dart';
import 'package:readee_app/features/auth/login.dart';
import 'package:readee_app/typography.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Readee!',
                  style: TypographyText.h1(Colors.cyan),
                ),
                const SizedBox(height: 10),
                Text(
                  'Before you start exploring and swapping books, please follow these simple guidelines to ensure a safe and enjoyable experience',
                  style: TypographyText.b3(Colors.grey),
                ),
                const SizedBox(height: 10),
                const GuidelineItem(
                  icon: Icons.check_circle,
                  title: 'Be Honest',
                  description:
                      'Ensure your book listings and descriptions are accurate and complete. Honesty builds trust in the community.',
                ),
                // const GuidelineItem(
                //   icon: Icons.security,
                //   title: 'Stay Safe',
                //   description:
                //       'Avoid sharing personal or sensitive information directly. Use public meeting points or trusted shipping methods for swaps.',
                // ),
                const GuidelineItem(
                  icon: Icons.chat,
                  title: 'Communicate Clearly',
                  description:
                      'Chat with the other user to confirm all swap details, including condition, timing, and delivery preferences.',
                ),
                const GuidelineItem(
                  icon: Icons.handshake,
                  title: 'Respect Others',
                  description:
                      'Treat your fellow users with kindness and professionalism. Report any inappropriate behavior or issues.',
                ),
                const GuidelineItem(
                  icon: Icons.checklist,
                  title: 'Take Responsibility',
                  description:
                      'Inspect the book and agree to terms before swapping. Once finalized, swaps cannot be undone.',
                ),
                const GuidelineItem(
                  icon: Icons.check,
                  title: 'Follow Up',
                  description:
                      'Confirm when the book has been shipped or received to keep the process smooth for both parties.',
                ),
                const SizedBox(height: 20),
                // "I Understand" Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.cyan, // Button color
                    foregroundColor: Colors.white, // Button color
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  ),
                  child: Text(
                    'I Understand',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GuidelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const GuidelineItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.cyan, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
