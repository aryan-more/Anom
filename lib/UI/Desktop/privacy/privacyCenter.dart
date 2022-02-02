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

class _PrivacyCenterDesktopState extends State<PrivacyCenterDesktop> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bar(),
      body: Row(
        children: [
          NavigationRouteRail(index: 0),
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
                      title: Text(toBlock[index]["Title"].toUpperCase()),
                      subtitle: Text(toBlock[index]["Subtitle"]),
                    ),
                  ),
                ),
                // TextField(
                //   controller: controller,
                // ),
                TextButton(
                  onPressed: () async {
                    List<String> block = [];
                    for (Map i in toBlock) {
                      if (i["Enable"]) {
                        block.add(i["Title"]);
                      }
                    }
                    print(await callNativeWin(block));
                    // print(await call(controller.text));
                  },
                  child: Text("Test"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
