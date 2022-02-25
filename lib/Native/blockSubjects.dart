import 'dart:convert';

import 'package:anom/Logic/secureio.dart';

class PrivacyCenter {
  List<Map<String, dynamic>> toBlock = [
    {"Title": "tracker", "Subtitle": "Blocks Trackers for better privacy", "Enable": false},
    {"Title": "spam", "Subtitle": "Blocks Malicious and Phishing Websites", "Enable": false},
    {"Title": "adult", "Subtitle": "Blocks Adult Websites", "Enable": false},
    {"Title": "social", "Subtitle": "Blocks Social Media Websites", "Enable": false},
  ];
  String capitalize(String original) {
    String capitalized = "";
    capitalized += original[0].toUpperCase();
    capitalized += original.substring(1).toLowerCase();
    return capitalized;
  }

  Future<void> getSavedPrefernce() async {
    if (await (await getFile("block.json")).exists()) {
      Map update = jsonDecode(await read(filename: "block.json"));
      for (var iter in toBlock) {
        iter["Enable"] = update[iter["Title"]];
      }
    }
  }

  Future<void> savePrefernce() async {
    Map<String, bool> prefernce = {};
    for (var iter in toBlock) {
      prefernce[iter["Title"]] = iter["Enable"];
    }
    await write(filename: "block.json", rawdata: jsonEncode(prefernce));
  }
}
