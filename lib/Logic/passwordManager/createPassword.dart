import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/passwordManager/onSave.dart';
import 'package:flutter/material.dart';
import 'package:anom/Logic/passwordManager/snackbar.dart';

class CreatePassword {
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();
  List<bool> obscure = [true, true];

  Future<void> validate({required BuildContext context}) async {
    if (password.text.isEmpty) {
      showSnackBar(context: context, error: "Password Cannot be Empty");
    } else if (password.text == confirm.text) {
      showLoading(context);
      await PasswordManager.createPassword(password.text);
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed("/passwordMenu");
    } else {
      showSnackBar(context: context, error: "Password doesn't match with Confirm Password");
    }
  }
}
