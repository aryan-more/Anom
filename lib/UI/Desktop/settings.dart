import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/settings.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:anom/UI/Desktop/navigationrail.dart';
import 'package:flutter/material.dart';

class SettingsDesktop extends StatefulWidget {
  const SettingsDesktop({
    Key? key,
    required this.customUrls,
  }) : super(key: key);
  final CustomUrlObj customUrls;
  @override
  State<SettingsDesktop> createState() => _SettingsDesktopState();
}

class _SettingsDesktopState extends State<SettingsDesktop> with SettingsMixMin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bar(),
      body: Row(
        children: [
          const NavigationRouteRail(index: 2),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 20, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Privacy Center",
                  style: TextStyle(fontSize: 25, color: Colors.blue),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Block custom urls",
                      style: TextStyle(fontSize: 22),
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
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "Password Manager",
                  style: const TextStyle(fontSize: 25, color: Colors.blue),
                ),
                if (PasswordManager.saveExist)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Export(Encrypted)",
                            style: TextStyle(fontSize: 22),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.north_west),
                            label: const Padding(
                              padding: EdgeInsets.only(top: 2.0, bottom: 2),
                              child: Text("Export"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Export(Decrypted)",
                            style: TextStyle(fontSize: 22),
                          ),
                          TextButton.icon(
                            onPressed: () {},
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
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Import(Encrypted Only)",
                      style: TextStyle(fontSize: 22),
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
          )),
        ],
      ),
    );
  }
}
