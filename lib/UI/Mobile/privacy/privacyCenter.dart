import 'package:anom/Native/Android/plugin.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/UI/Mobile/drawer.dart';
import 'package:flutter/material.dart';

class PrivacyCenterMobile extends StatefulWidget {
  const PrivacyCenterMobile({Key? key}) : super(key: key);

  @override
  _PrivacyCenterMobileState createState() => _PrivacyCenterMobileState();
}

class _PrivacyCenterMobileState extends State<PrivacyCenterMobile> with PrivacyCenter {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Center"),
      ),
      drawer: DrawerRoute(index: 0),
      body: Column(
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
            padding: const EdgeInsets.all(12.0),
            child: TextButton(
              onPressed: () async {
                List<String> block = [];
                for (Map i in toBlock) {
                  if (i["Enable"]) {
                    block.add(i["Title"]);
                  }
                }
                await nativeCall(block);
              },
              child: SizedBox(
                child: Text(
                  "Block",
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
