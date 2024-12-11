import 'package:flutter/material.dart';
import 'package:readee_app/widget/generateCodeMySelf.dart';
import 'package:readee_app/widget/verifyCodeMySelf.dart';

class Flutter2FAMySelf {
  Future<void> activate(
      {required BuildContext context,
      required String appName,
      required String email}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GenerateCodeMySelf(appName: appName, email: email)),
    );
  }

  Future<void> verify({required BuildContext context, required page}) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VerifyCodeMySelf(successPage: page,)),
    );
  }
}
