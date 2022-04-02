import 'package:anom/Native/Android/plugin.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/UI/Mobile/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spin;

class PrivacyCenterMobile extends StatefulWidget {
  const PrivacyCenterMobile({Key? key, required this.center}) : super(key: key);

  final PrivacyCenter center;
  @override
  _PrivacyCenterMobileState createState() => _PrivacyCenterMobileState();
}

class _PrivacyCenterMobileState extends State<PrivacyCenterMobile> {
  String status = "Loading";

  void onBoot() async {
    bool result = await getServiceStatus();
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      status = result ? "Stop" : "Start";
    });
  }

  @override
  void initState() {
    super.initState();
    onBoot();
  }

  void applyChanges() async {
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
    try {
      status = (await nativeCall(block)) ? "Stop" : "Start";
      await widget.center.savePrefernce();
      Navigator.of(context).pop();
      setState(() {});
    } catch (_) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Something Went Wrong!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Center"),
      ),
      drawer: DrawerRoute(index: 0),
      body: Column(
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
            padding: const EdgeInsets.all(12.0),
            child: TextButton(
              onPressed: () async {
                applyChanges();
              },
              child: SizedBox(
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                ),
                width: double.infinity,
              ),
            ),
          )
        ],
      ),
    );
  }
}
