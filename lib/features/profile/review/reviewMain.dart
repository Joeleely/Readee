import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:readee_app/features/profile/review/ratingScreen.dart';
import 'package:readee_app/features/profile/review/reviewScreen.dart';
import 'package:readee_app/features/profile/widget/constant.dart';

class ReviewMainPage extends StatelessWidget {
  const ReviewMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LineAwesomeIcons.arrow_left), // Back button
        ),
        title: const Text(
          'Review and Rating',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
                leading: const Icon(LineAwesomeIcons.star),
                title: const Text('Your Review'),
                onTap: () {
                  // Navigate to Review Page
                  Get.to(() => const ReviewScreen());
                },
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                )),
            const Divider(), // Add a separator
            ListTile(
                leading: const Icon(LineAwesomeIcons.thumbs_up),
                title: const Text('Your Rating'),
                onTap: () {
                  // Navigate to Rating Page
                  Get.to(() => const RatingScreen());
                },
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                )),
          ],
        ),
      ),
    );
  }
}
