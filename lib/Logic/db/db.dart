import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anom/Logic/db/native.dart';
import 'package:anom/Logic/secureio.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

enum ShowDetails {
  password,
  username,
  web,
}

class Password {
  late String encryptedusername;
  late String encryptedpassword;
  late String encryptedwebsite;
  late int createdOn;
  late int modifiedOn;
  String? _cacheusername;
  String? _cachepassword;
  String? _cachewebsite;

  void forget() {
    _cacheusername = null;
    _cachepassword = null;
    _cachewebsite = null;
  }

  String get decryptedusername {
    _cacheusername ??= decrypt64(bin: encryptedusername, hashedPassword: PasswordManager.hashedPassword);
    return _cacheusername!;
  }

  String get decryptedpassword {
    _cachepassword ??= decrypt64(bin: encryptedpassword, hashedPassword: PasswordManager.hashedPassword);
    return _cachepassword!;
  }

  String get decryptedwebsite {
    _cachewebsite ??= decrypt64(bin: encryptedwebsite, hashedPassword: PasswordManager.hashedPassword);
    return _cachewebsite!;
  }

  Password({required String userName, required String passWord, required String webSite, int? createdTime, int? modifiedTime}) {
    encryptedusername = encrypt64(raw: userName, hashedPassword: PasswordManager.hashedPassword);
    encryptedpassword = encrypt64(raw: passWord, hashedPassword: PasswordManager.hashedPassword);
    encryptedwebsite = encrypt64(raw: webSite, hashedPassword: PasswordManager.hashedPassword);
    createdOn = createdTime ?? DateTime.now().millisecondsSinceEpoch;
    modifiedOn = modifiedTime ?? DateTime.now().millisecondsSinceEpoch;
  }
  Password.fromMap(Map temp) {
    encryptedusername = temp["username"];
    encryptedpassword = temp["password"];
    encryptedwebsite = temp["website"];
    createdOn = temp["CreationTime"];
    modifiedOn = temp["ModificationTime"];
  }

  Future<void> update({required String userName, required String passWord, required String webSite}) async {
    encryptedusername = encrypt64(raw: userName, hashedPassword: PasswordManager.hashedPassword);
    forget();
    encryptedpassword = encrypt64(raw: passWord, hashedPassword: PasswordManager.hashedPassword);
    encryptedwebsite = encrypt64(raw: webSite, hashedPassword: PasswordManager.hashedPassword);
    await PasswordDB.db.update(PasswordDB.passwordtable, {"username": encryptedusername, "password": encryptedpassword, "ModificationTime": DateTime.now().microsecondsSinceEpoch, "website": encryptedwebsite}, where: "CreationTime = $createdOn");
  }

  Map<String, dynamic> toMap() {
    return {
      "username": encryptedusername,
      "password": encryptedpassword,
      "website": encryptedwebsite,
      "CreationTime": createdOn,
      "ModificationTime": modifiedOn,
    };
  }
}

class GoogleDriveToken {
  static String? data;
  static String? type;
  static DateTime? expiry;
  static String? refreshToken;
  static Uint8List? _todecrypt;

  static bool get saveExist => _todecrypt != null;

  static Future<void> init() async {
    if (await fileExist("GDriveConfig")) {
      _todecrypt = await readBin(filename: "GDriveConfig");
    }
  }

  static void forget() {
    data = null;
    type = null;
    expiry = null;
    refreshToken = null;
  }

  static Map toJson() {
    if (data == null) {
      return {};
    }
    return {"data": data, "type": type, "expiry": expiry!.toIso8601String(), "refreshToken": refreshToken};
  }

  static Future<void> saveConfig() async {
    await writeBin(filename: "GDriveConfig", bits: encrypt(raw: jsonEncode(toJson()), hashedPassword: PasswordManager.hashedPassword));
  }

  static bool loadConfig() {
    try {
      Map temp = jsonDecode(decrypt(bin: _todecrypt!, hashedPassword: PasswordManager.hashedPassword));
      if (temp.isNotEmpty) {
        data = temp["data"];
        type = temp["type"];
        expiry = DateTime.parse(temp["expiry"]);
        refreshToken = temp["refreshToken"];
      }

      return true;
    } catch (_) {}
    return false;
  }

  static Future<void> deleteToken() async {
    await (await getFile("GDriveConfig")).delete();
    _todecrypt = null;
    forget();
  }
}

class PasswordManager {
  static const String deletetable = "DELETED";
  static const String passwordtable = "PASSWORD";
  static Uint8List? _todecrypt;
  static late List<int> hashedPassword;
  static bool get saveExist => _todecrypt != null;
  static Future<void> init() async {
    if (await fileExist("sample")) {
      _todecrypt = await readBin(filename: "sample");
    }
    await PasswordDB.init();
    await GoogleDriveToken.init();
  }

  static void forget() {
    hashedPassword = [];
    PasswordDB.forget();
    GoogleDriveToken.forget();
    print("forget");
  }

  static late List<Password> allPasswords;

  static bool checkPassword(String pass) {
    try {
      var temp = hashSha256(pass);
      print(temp);
      decrypt(bin: _todecrypt!, hashedPassword: temp);
      hashedPassword = temp;
      if (GoogleDriveToken.saveExist) {
        GoogleDriveToken.loadConfig();
      }
      return true;
    } catch (_) {}
    return false;
  }

  static Future<void> createPassword(String raw) async {
    hashedPassword = hashSha256(raw);
    print(hashedPassword);
    _todecrypt = encrypt(raw: "anom", hashedPassword: hashedPassword);
    allPasswords = [];
    await writeBin(filename: "sample", bits: _todecrypt!);
  }
}

class PasswordDB {
  static late Database db;
  static String deletetable = "DELETED";
  static String passwordtable = "PASSWORD";

  static void forget() {
    for (var item in PasswordManager.allPasswords) {
      item.forget();
    }
  }

  static Future<void> init() async {
    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      db = await databaseFactoryFfi.openDatabase("${await getPath()}/ps.sqlite");
    } else {
      db = await initNativeDB();
    }

    if (await tableDoesNotExist(passwordtable)) {
      await db.rawQuery("""CREATE TABLE $passwordtable (
      CreationTime INTEGER PRIMARY KEY,
      ModificationTime INTEGER,
      password TEXT,
      username TEXT,
      website TEXT
    )""");
    }
    PasswordManager.allPasswords = [];
    var temp = await db.rawQuery("SELECT * FROM $passwordtable");
    for (var item in temp) {
      PasswordManager.allPasswords.add(Password.fromMap(item));
    }
  }

  static Future<bool> tableDoesNotExist(String table) async {
    var data = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='$table'");
    return data.isEmpty;
  }

  static Future<void> delete(Password todelete) async {
    if (await tableDoesNotExist(deletetable)) {
      await db.rawQuery("""
        CREATE TABLE $deletetable(
          deletedkeys int PRIMARY KEY
        )
        """);
    }
    await db.insert(deletetable, {"deletedkeys": todelete.createdOn});
    await db.delete(passwordtable, where: "CreationTime = ${todelete.createdOn}");
    PasswordManager.allPasswords.remove(todelete);
  }

  static Future<void> add(Password password) async {
    PasswordManager.allPasswords.add(password);
    await db.insert(passwordtable, password.toMap());
  }
}
