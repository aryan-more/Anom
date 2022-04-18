import 'dart:io';

import 'package:anom/Logic/secureio.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

MethodChannel get methodChannel => const MethodChannel("anom");

Future<String> invokePrivacyMethodwin(PrivacyCenter center) async {
  MethodChannel channel = methodChannel;
  var args = await _urls(center);
  return await channel.invokeMethod("privacy", args);
}

Future<List<String>> _urls(PrivacyCenter center) async {
  Set<String> raw = {};
  for (var item in center.toBlock) {
    if (item.enabled) {
      raw.addAll((await item.getUrls()));
    }
  }
  return raw.toList();
}

String join(List<String> raw) {
  StringBuffer buffer = StringBuffer();
  for (var item in raw) {
    buffer.writeln(item);
  }
  return buffer.toString();
}

Future<void> invokePrivacyMethodAndroid(PrivacyCenter center) async {
  MethodChannel channel = methodChannel;
  await channel.invokeMethod("privacy", join(await _urls(center)));
}

Future<bool> getServiceStatus() async {
  // Androif Only
  MethodChannel channel = methodChannel;
  bool result = await channel.invokeMethod('status');
  return result;
}

Future<void> exportPassword() async {
  if (Platform.isAndroid) {
    var channel = methodChannel;
    await channel.invokeMethod("export", await readBin(filename: "ps.sqlite"));
  } else if (Platform.isWindows) {
    var path = (await getApplicationDocumentsDirectory()).path;
    (await getFile("ps.sqlite")).copy("$path/password.anomps");
  }
}
