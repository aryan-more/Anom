import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/passwordManager/onSave.dart';
import 'package:anom/Logic/settings.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/Native/plugin.dart';
import 'package:anom/UI/Mobile/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsMobile extends StatefulWidget {
  const SettingsMobile({
    Key? key,
    required this.customUrls,
  }) : super(key: key);
  final CustomUrlObj customUrls;
  @override
  State<SettingsMobile> createState() => _SettingsMobileState();
}

class _SettingsMobileState extends State<SettingsMobile> with SettingsMixMin {
  double title = 22, subtitle = 14;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerRoute(index: 2),
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Center",
                style: TextStyle(fontSize: title, color: Colors.blue),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Block custom urls",
                    style: TextStyle(fontSize: subtitle),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      addCustomUrls(widget.customUrls, context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("ADD"),
                  ),
                ],
              ),
              SizedBox(
                height: title,
              ),
              Text(
                "Password Manager",
                style: TextStyle(fontSize: title, color: Colors.blue),
              ),
              if (PasswordManager.saveExist)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Export Passwords",
                          style: TextStyle(fontSize: subtitle),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            if (await managePermission(context)) {
                              await export(context);
                            }
                          },
                          icon: const Icon(Icons.north_west),
                          label: const Padding(
                            padding: EdgeInsets.only(top: 2.0, bottom: 2),
                            child: Text("Export"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Import Passwords",
                    style: TextStyle(fontSize: subtitle),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.south_east),
                    label: const Padding(
                      padding: EdgeInsets.only(top: 2.0, bottom: 2),
                      child: Text("Import"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
