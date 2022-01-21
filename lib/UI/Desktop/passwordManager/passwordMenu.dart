import 'package:anom/Logic/passwordManager/menu.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:anom/UI/Desktop/navigationrail.dart';
import 'package:flutter/material.dart';

class PasswordMangerMenuDesktop extends StatefulWidget {
  const PasswordMangerMenuDesktop({Key? key}) : super(key: key);

  @override
  _PasswordMangerMenuDesktopState createState() => _PasswordMangerMenuDesktopState();
}

class _PasswordMangerMenuDesktopState extends State<PasswordMangerMenuDesktop> with PasswordMenu {
  @override
  Widget build(BuildContext context) {
    loadPassword(context);
    print(password.passwords);
    return Scaffold(
      appBar: bar(),
      body: Row(
        children: [NavigationRouteRail(index: 1), Expanded(child: buildList(setState))],
      ),
      floatingActionButton: floatingActionButton(context, setState),
    );
  }
}
