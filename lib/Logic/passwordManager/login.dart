import 'package:anom/Logic/passwordManager/password.dart';
import 'package:anom/Logic/passwordManager/snackbar.dart';
import 'package:flutter/material.dart';

class LoginLogic {
  bool boot = true;
  bool obscure = true;
  TextEditingController controller = TextEditingController();
  late Password password;

  void loadPassword(BuildContext context) {
    var temp = ModalRoute.of(context)!.settings.arguments as Map;
    password = temp["passwords"];
  }

  void login({required BuildContext context}) {
    if (password.checkPassword(controller.text)) {
      Navigator.of(context).pushReplacementNamed("/passwordMenu", arguments: {"passwords": password});
    } else {
      showSnackBar(context: context, error: "Password Doesn't Match");
    }
  }
}
