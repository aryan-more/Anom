import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/Native/plugin.dart';
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
  void initState() {
    super.initState();
    widget.center.showError(context);
  }

  @override
  Widget build(BuildContext context) {
    var toBlock = widget.center.toBlock;
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
                      value: toBlock[index].enabled,
                      onChanged: (x) {
                        setState(() {
                          toBlock[index].enabled = x!;
                        });
                      },
                      title: Text(toBlock[index].title),
                      subtitle: Text(toBlock[index].subtitle),
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

                      await invokePrivacyMethodwin(widget.center);
                      await widget.center.savePrefernce();
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
