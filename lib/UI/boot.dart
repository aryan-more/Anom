import 'dart:io';

import 'package:anom/Logic/secureio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spin;

void onBoot(BuildContext context) async {
  Directory dir = Directory(await getPath());
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  Navigator.of(context).pushReplacementNamed("/loadPasswords");
}

class Boot extends StatefulWidget {
  const Boot({Key? key}) : super(key: key);

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onBoot(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: spin.SpinKitRing(
          color: Colors.blue,
        ),
      ),
    );
  }
}
