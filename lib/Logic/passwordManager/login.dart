import 'package:anom/Logic/passwordManager/password.dart';
import 'package:anom/Logic/passwordManager/snackbar.dart';
import 'package:flutter/material.dart';

class LoginLogic {
  bool boot = true;
  bool obscure = true;
  TextEditingController controller = TextEditingController();

  void login({required BuildContext context, required Passwords password}) {
    if (password.checkPassword(controller.text)) {
      Navigator.of(context).pushReplacementNamed("/passwordMenu", arguments: {"passwords": password});
    } else {
      showSnackBar(context: context, error: "Password Doesn't Match");
    }
  }
}
