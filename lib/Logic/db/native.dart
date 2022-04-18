import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> initNativeDB(String path) async {
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();

    return await databaseFactoryFfi.openDatabase(path);
  }
  return await openDatabase(path);
}
