import 'package:flutter/services.dart';

MethodChannel channel = const MethodChannel("anom");
Future<bool> nativeCall(List<String> subjects) async {
  String raw;
  String data = "";
  for (var subject in subjects) {
    raw = await rootBundle.loadString("assets/$subject");
    data += raw.replaceAll("\r", "") + "\n";
  }
  bool result = await channel.invokeMethod("privacy", data);
  return result;
}

Future<bool> getServiceStatus() async {
  bool result = await channel.invokeMethod('status');
  return result;
}
