import 'package:anom/Native/Windows/plugin.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:anom/UI/Desktop/navigationrail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spin;

class PrivacyCenterDesktop extends StatefulWidget {
  const PrivacyCenterDesktop({Key? key}) : super(key: key);

  @override
  _PrivacyCenterDesktopState createState() => _PrivacyCenterDesktopState();
}

class _PrivacyCenterDesktopState extends State<PrivacyCenterDesktop> with PrivacyCenter {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bar(),
      body: Row(
        children: [
          const NavigationRouteRail(index: 0),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: toBlock.length,
                    itemBuilder: (context, index) => CheckboxListTile(
                      value: toBlock[index]["Enable"],
                      onChanged: (x) {
                        setState(() {
                          toBlock[index]["Enable"] = x;
                        });
                      },
                      title: Text(capitalize(toBlock[index]["Title"])),
                      subtitle: Text(toBlock[index]["Subtitle"]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () async {
                      List<String> block = [];
                      for (Map i in toBlock) {
                        if (i["Enable"]) {
                          block.add(i["Title"]);
                        }
                      }
                      print(await callNativeWin(block));
                    },
                    child: const Text("Block"),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
