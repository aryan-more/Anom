import 'package:anom/Logic/passwordManager/password.dart';
import 'package:flutter/material.dart';

void loadPassword(BuildContext context) async {
  // await Future.delayed(Duration(seconds: 7));
  Password password = Password();
  if (await password.exist()) {
    await password.load();
    Navigator.of(context).pushReplacementNamed("/loginPassword", arguments: {"passwords": password});
  } else {
    Navigator.of(context).pushReplacementNamed("/createPassword");
  }
}
