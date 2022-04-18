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
