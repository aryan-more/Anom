import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/passwordManager/snackbar.dart';
import 'package:flutter/material.dart';

class LoginLogic {
  bool boot = true;
  bool obscure = true;
  TextEditingController controller = TextEditingController();

  void login({required BuildContext context}) {
    if (PasswordManager.checkPassword(controller.text)) {
      Navigator.of(context).pushReplacementNamed("/passwordMenu");
    } else {
      showSnackBar(context: context, error: "Password Doesn't Match");
    }
  }
}
