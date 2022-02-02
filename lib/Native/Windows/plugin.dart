import 'package:flutter/services.dart';

Future<String> callNativeWin(List<String> toblock) async {
  MethodChannel channel = const MethodChannel("anom");

  try {
    var result = await channel.invokeMethod("privacy", toblock);
    print(result);
    print(result.runtimeType);
    return "Fine";
  } on NoSuchMethodError catch (e) {
    print(e);
    return e.toString();
  } on PlatformException catch (e) {
    print(e);
    return e.message != null ? e.message! : "Adminstartive Permission Required";
  } catch (_) {
    print(_);
    return "Something Went Wrong";
  }
}

Future<String> call(String string) async {
  MethodChannel channel = const MethodChannel("anom");

  try {
    var result = await channel.invokeMethod(string);
    print(result);
    print(result.runtimeType);
    return "Fine";
  } on NoSuchMethodError catch (e) {
    print(e);
    return e.toString();
  } on PlatformException catch (e) {
    print(e);
    return e.message != null ? e.message! : "Adminstartive Permission Required";
  } catch (_) {
    print(_);
    return "Something Went Wrong";
  }
}
