import 'package:anom/Logic/passwordManager/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spin;

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      child: spin.SpinKitRing(
        color: Colors.blue,
      ),
    ),
    barrierDismissible: true,
  );
}

Future<void> onSave(Passwords password, BuildContext context) async {
  showLoading(context);
  await password.dump();
  Navigator.of(context).pop();
}