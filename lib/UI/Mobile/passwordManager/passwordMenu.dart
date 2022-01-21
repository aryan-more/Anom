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
    loadPassword(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Password Manager"),
      ),
      drawer: DrawerRoute(index: 1),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: buildList(setState),
      ),
      floatingActionButton: floatingActionButton(context, setState),
    );
  }
}
