import 'package:flutter/services.dart';

Future<String> callNativeWin(List<String> toblock) async {
  MethodChannel channel = const MethodChannel("anom");

  try {
    await channel.invokeMethod("privacy", toblock);
    return "Fine";
  } on NoSuchMethodError catch (e) {
    return e.toString();
  } on PlatformException catch (e) {
    return e.message != null ? e.message! : "Adminstartive Permission Required";
  } catch (_) {
    return "Something Went Wrong";
  }
}
