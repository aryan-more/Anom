import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/passwordManager/menu.dart';
import 'package:anom/UI/Mobile/drawer.dart';
import 'package:flutter/material.dart';

class PasswordMangerMenuMobile extends StatefulWidget {
  const PasswordMangerMenuMobile({Key? key}) : super(key: key);

  @override
  _PasswordMangerMenuMobileState createState() => _PasswordMangerMenuMobileState();
}

class _PasswordMangerMenuMobileState extends State<PasswordMangerMenuMobile> with PasswordMenu {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Manager"),
      ),
      drawer: DrawerRoute(
          index: 1,
          func: () {
            PasswordManager.forget();
          }),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: buildList(setState),
      ),
      floatingActionButton: floatingActionButton(context, setState),
    );
  }
}
