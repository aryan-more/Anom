import 'package:anom/Native/Windows/plugin.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:anom/UI/Desktop/navigationrail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spin;

class PrivacyCenterDesktop extends StatefulWidget {
  const PrivacyCenterDesktop({Key? key, required this.center}) : super(key: key);
  final PrivacyCenter center;

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
          const NavigationRouteRail(index: 0),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.center.toBlock.length,
                    itemBuilder: (context, index) => CheckboxListTile(
                      value: widget.center.toBlock[index]["Enable"],
                      onChanged: (x) {
                        setState(() {
                          widget.center.toBlock[index]["Enable"] = x;
                        });
                      },
                      title: Text(capitalize(widget.center.toBlock[index]["Title"])),
                      subtitle: Text(widget.center.toBlock[index]["Subtitle"]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => const Dialog(
                          backgroundColor: Colors.transparent,
                          child: spin.SpinKitRing(color: Colors.blue),
                        ),
                        barrierDismissible: false,
                      );
                      List<String> block = [];
                      for (Map i in widget.center.toBlock) {
                        if (i["Enable"]) {
                          block.add(i["Title"]);
                        }
                      }
                      await callNativeWin(block);
                      Navigator.of(context).pop();
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
