import 'package:anom/Logic/passwordManager/loading.dart';
import 'package:anom/UI/Mobile/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spin;

class LoadingPasswordManagerMobile extends StatefulWidget {
  const LoadingPasswordManagerMobile({Key? key}) : super(key: key);

  @override
  _LoadingPasswordManagerMobileState createState() => _LoadingPasswordManagerMobileState();
}

class _LoadingPasswordManagerMobileState extends State<LoadingPasswordManagerMobile> {
  @override
  void initState() {
    super.initState();
    loadPassword(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Manager"),
      ),
      drawer: DrawerRoute(index: 1),
      body: const Center(
        child: spin.SpinKitRing(
          color: Colors.blue,
        ),
      ),
    );
  }
}
