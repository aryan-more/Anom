import 'package:anom/Logic/passwordManager/onSave.dart';
import 'package:anom/Logic/passwordManager/password.dart';
import 'package:anom/Logic/privacyCenter.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:anom/UI/Desktop/navigationrail.dart';
import 'package:flutter/material.dart';

class SettingsDesktop extends StatefulWidget {
  const SettingsDesktop({
    Key? key,
    required this.passwords,
    required this.customUrls,
  }) : super(key: key);
  final Passwords passwords;
  final CustomUrls customUrls;
  @override
  State<SettingsDesktop> createState() => _SettingsDesktopState();
}

class _SettingsDesktopState extends State<SettingsDesktop> {
  void addCustomUrls() {
    TextEditingController controller = TextEditingController(text: widget.customUrls.tostring());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("One url per line"),
        content: SizedBox(
          height: 200,
          child: TextField(
            controller: controller,
            maxLines: 500,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                showLoading(context);
                await widget.customUrls.updateUrls(controller.text);
                Navigator.of(context).pop();
              },
              child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 2),
                    child: Text(
                      "Submit",
                      textAlign: TextAlign.center,
                    ),
                  )))
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

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
                        addCustomUrls();
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
                if (widget.passwords.saveExist)
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
