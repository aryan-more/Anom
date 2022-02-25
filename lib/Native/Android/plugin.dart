import 'package:flutter/services.dart';

Future<void> nativeCall(List<String> subjects) async {
  MethodChannel channel = const MethodChannel("anom");
  String raw;
  String data = "";
  for (var subject in subjects) {
    raw = await rootBundle.loadString("assets/$subject");
    data += raw.replaceAll("\r", "") + "\n";
  }
  String result = await channel.invokeMethod("privacy", data);
}
