import 'package:anom/Logic/passwordManager/onSave.dart';
import 'package:anom/Logic/passwordManager/password.dart';
import 'package:anom/Logic/secureio.dart';
import 'package:flutter/material.dart';
import 'package:anom/Logic/passwordManager/snackbar.dart';

class CreatePassword {
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();
  List<bool> obscure = [true, true];

  Future<void> validate({required BuildContext context, required Passwords passwords}) async {
    if (password.text.isEmpty) {
      showSnackBar(context: context, error: "Password Cannot be Empty");
    } else if (password.text == confirm.text) {
      passwords.hashedPassword = hashSha256(password.text);
      passwords.saveExist = true;
      await onSave(passwords, context);
      Navigator.of(context).pushReplacementNamed("/passwordMenu", arguments: {"passwords": passwords});
    } else {
      showSnackBar(context: context, error: "Password doesn't match with Confirm Password");
    }
  }
}
