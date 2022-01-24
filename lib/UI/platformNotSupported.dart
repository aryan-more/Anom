import 'package:flutter/material.dart';

class PlatformNotSupported extends StatelessWidget {
  const PlatformNotSupported({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Platform Not Supported Currently"),
      ),
    );
  }
}
