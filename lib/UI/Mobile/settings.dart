import 'package:anom/Logic/passwordManager/password.dart';
import 'package:anom/Logic/privacyCenter.dart';
import 'package:anom/UI/Mobile/drawer.dart';
import 'package:flutter/material.dart';

class SettingsMobile extends StatefulWidget {
  const SettingsMobile({
    Key? key,
    required this.passwords,
    required this.customUrls,
  }) : super(key: key);
  final Passwords passwords;
  final CustomUrls customUrls;
  @override
  State<SettingsMobile> createState() => _SettingsMobileState();
}

class _SettingsMobileState extends State<SettingsMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerRoute(index: 2),
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(color: Colors.yellow),
    );
  }
}
