import 'package:anom/Logic/passwordManager/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spin;

Future<void> onSave(Password password, BuildContext context) async {
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
  await password.dump();
  Navigator.of(context).pop();
}
