import 'package:anom/Logic/secureio.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initNativeDB() async {
  return await openDatabase("${await getPath()}/ps.sqlite");
}
