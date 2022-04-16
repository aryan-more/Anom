import 'package:anom/Logic/passwordManager/onSave.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/Native/plugin.dart';
import 'package:anom/UI/Mobile/drawer.dart';
import 'package:flutter/material.dart';

class PrivacyCenterMobile extends StatefulWidget {
  const PrivacyCenterMobile({Key? key, required this.center}) : super(key: key);

  final PrivacyCenter center;
  @override
  _PrivacyCenterMobileState createState() => _PrivacyCenterMobileState();
}

class _PrivacyCenterMobileState extends State<PrivacyCenterMobile> {
  String status = "Loading";
  bool overridevpn = false;
  bool vpnStatus = false;
  bool init = false;
  Map<String, bool> old = {};

  void onBoot() async {
    widget.center.showError(context);
    vpnStatus = await getServiceStatus();
    init = true;

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      status = vpnStatus ? "Stop" : "Start";
    });
  }

  @override
  void initState() {
    super.initState();
    onBoot();
  }

  Future<void> applyChanges() async {
    showLoading(context);

    try {
      await invokePrivacyMethodAndroid(widget.center);
      await Future.delayed(Duration(milliseconds: 500));
      vpnStatus = await getServiceStatus();
      status = vpnStatus ? "Stop" : "Start";
      print(status);
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
    if (init && !vpnStatus) {
      for (var item in widget.center.toBlock) {
        if (item.enabled != old[item.title]) {
          overridevpn = true;
          status = "Apply Changes";
          break;
        }
      }
    }
    old = widget.center.snapshot;
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
                value: widget.center.toBlock[index].enabled,
                onChanged: (x) {
                  setState(() {
                    widget.center.toBlock[index].enabled = x!;
                  });
                },
                title: Text(widget.center.toBlock[index].title),
                subtitle: Text(widget.center.toBlock[index].subtitle),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextButton(
              onPressed: () async {
                if (overridevpn) {
                  await applyChanges();
                  overridevpn = false;
                }
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
