import 'dart:convert';

import 'package:anom/Logic/secureio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UrlObj {
  final String title, subtitle;
  bool enabled = false;
  bool get show => true;
  UrlObj({
    required this.title,
    required this.subtitle,
  });
  Future<String> getRawUrls() async {
    var raw = (await rootBundle.loadString("assets/${title.toLowerCase()}")).replaceAll("\r", "");
    return raw;
  }

  Future<List<String>> getUrls() async {
    return (await getRawUrls()).split('\n');
  }
}

class CustomUrlObj extends UrlObj {
  CustomUrlObj() : super(title: "Custom", subtitle: "Custom Urls");
  List<String> urls = [];
  bool customUrlsExists = false;
  Future<void> loadUrls() async {
    if (await ((await getFile("custom.urls")).exists())) {
      customUrlsExists = true;
      var temp = await read(filename: "custom.urls");
      if (temp.isNotEmpty) {
        urls = temp.replaceAll('\r', "").split('\n');
      }
    }
  }

  String tostring() {
    if (customUrlsExists) {
      StringBuffer buffer = StringBuffer();
      for (String item in urls) {
        buffer.write("$item\n");
      }

      return buffer.toString().trimRight();
    }
    return "";
  }

  Future<void> updateUrls(String raw) async {
    if (raw != "") {
      urls = raw.replaceAll('\r', "").split('\n');
      customUrlsExists = true;
    } else {
      urls = [];
      customUrlsExists = false;
    }
    await write(filename: "custom.urls", rawdata: raw);
  }

  @override
  Future<String> getRawUrls() async {
    return tostring();
  }

  @override
  Future<List<String>> getUrls() async {
    return urls;
  }

  @override
  bool get show => customUrlsExists && urls.isNotEmpty;
}

class PrivacyCenter {
  CustomUrlObj customUrlObj = CustomUrlObj();
  bool saveCorrupted = false;

  List<UrlObj> toblock = [
    UrlObj(title: "Tracker", subtitle: "Blocks Trackers for better privacy"),
    UrlObj(title: "Spam", subtitle: "Blocks Malicious and Phishing Websites"),
    UrlObj(title: "Adult", subtitle: "Blocks Adult Websites"),
    UrlObj(title: "Social", subtitle: "Blocks Social Media Websites"),
  ];

  List<UrlObj> get toBlock {
    List<UrlObj> temp = [];
    for (var item in toblock) {
      if (item.show) {
        temp.add(item);
      }
    }
    return temp;
  }

  Future<void> getSavedPrefernce() async {
    await customUrlObj.loadUrls();
    toblock.add(customUrlObj);
    try {
      if (await (await getFile("block.json")).exists()) {
        Map update = jsonDecode(await read(filename: "block.json"));
        for (var iter in toblock) {
          if (iter == customUrlObj) {
            iter.enabled = update[iter.title] ?? false;
          } else {
            iter.enabled = update[iter.title];
          }
        }
      }
    } catch (_) {
      saveCorrupted = true;
    }
  }

  Future<void> showError(BuildContext context) async {
    if (!saveCorrupted) {
      return;
    }
    await Future.delayed(Duration(milliseconds: 300));
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Saved Preferences Are Corrupted , Switching all preferences to default."),
              actions: [
                TextButton(
                    onPressed: () async {
                      await (await getFile("block.json")).delete();
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"))
              ],
            ));
  }

  Map<String, bool> get snapshot {
    Map<String, bool> temp = {};
    for (var item in toBlock) {
      temp[item.title] = item.enabled;
    }
    return temp;
  }

  Future<void> savePrefernce() async {
    await write(filename: "block.json", rawdata: jsonEncode(snapshot));
  }
}
