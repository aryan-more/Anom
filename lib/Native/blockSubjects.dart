import 'dart:convert';

import 'package:anom/Logic/secureio.dart';

List<Map<String, dynamic>> toBlock = [
  {"Title": "tracker", "Subtitle": "Blocks Trackers for better privacy", "Enable": false},
  {"Title": "adult", "Subtitle": "Blocks Adult Websites", "Enable": false},
  {"Title": "spam", "Subtitle": "Blocks Malicious and Phishing Websites", "Enable": false},
  {"Title": "social", "Subtitle": "Blocks Social Media Websites", "Enable": false},
];

String capitalize(String original) {
  String capitalized = "";
  capitalized += original[0].toUpperCase();
  capitalized += original.substring(1).toLowerCase();
  return "";
}

Future<Map<String, bool>> getSavedPrefernce() async {
  if (await (await getFile("block.json")).exists()) {
    return jsonDecode(await read(filename: "block.json")) as Map<String, bool>;
  }
  // Map<String, bool> defaultpreference = {};
  // for (String i in toBlock.keys) {
  //   defaultpreference[i] = false;
  // }
  return {};
}
