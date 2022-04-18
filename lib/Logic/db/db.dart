import 'package:anom/Logic/db/drive.dart';
import 'package:anom/Logic/db/native.dart';
import 'package:anom/Logic/secureio.dart';
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

  Future<void> copy(Map item) async {
    encryptedusername = item["username"];
    encryptedpassword = item["password"];
    encryptedwebsite = item["website"];
    modifiedOn = item["ModificationTime"];
    await PasswordDB.update(this);
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

  Future<void> update({required String userName, required String passWord, required String webSite, int? customModificationTime}) async {
    forget();
    encryptedusername = encrypt64(raw: userName, hashedPassword: PasswordManager.hashedPassword);
    encryptedpassword = encrypt64(raw: passWord, hashedPassword: PasswordManager.hashedPassword);
    encryptedwebsite = encrypt64(raw: webSite, hashedPassword: PasswordManager.hashedPassword);
    modifiedOn = customModificationTime ?? DateTime.now().millisecondsSinceEpoch;
    await PasswordDB.update(this);
  }

  Future<void> migrate(List<int> newpassword) async {
    encryptedusername = encrypt64(raw: decryptedusername, hashedPassword: newpassword);
    encryptedpassword = encrypt64(raw: decryptedpassword, hashedPassword: newpassword);
    encryptedwebsite = encrypt64(raw: decryptedwebsite, hashedPassword: newpassword);
    await PasswordDB.update(this);
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

  Map<String, dynamic> toUpdateMap() {
    return {
      "username": encryptedusername,
      "password": encryptedpassword,
      "website": encryptedwebsite,
      "ModificationTime": modifiedOn,
    };
  }
}

class PasswordManager {
  static const String deletetable = "DELETED";
  static const String passwordtable = "PASSWORD";
  static late List<int> hashedPassword;
  static Future<void> init() async {
    await PasswordDB.init();
    await GoogleDriveToken.init();
    await Update.load();
  }

  static void forget() {
    hashedPassword = [];
    PasswordDB.forget();
    GoogleDriveToken.forget();
  }

  static late List<Password> allPasswords;

  static bool checkPassword(String pass) {
    try {
      var temp = hashSha256(pass);
      decrypt64(bin: PasswordDB.todecrypt!, hashedPassword: temp);
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
    PasswordDB.todecrypt = encrypt64(raw: "anom", hashedPassword: hashedPassword);
    allPasswords = [];
    PasswordDB.db.insert("ToDecrypt", {"raw": PasswordDB.todecrypt});
  }
}

class PasswordDB {
  static late Database db;
  static String deletetable = "DELETED";
  static String passwordtable = "PASSWORD";

  static String? todecrypt;
  static bool get saveExist => todecrypt != null;

  static void forget() {
    for (var item in PasswordManager.allPasswords) {
      item.forget();
    }
  }

  static Future<void> changePassword(List<int> newpass) async {
    for (var item in PasswordManager.allPasswords) {
      await item.migrate(newpass);
    }
    todecrypt = encrypt64(raw: "anom", hashedPassword: newpass);
    await db.update("ToDecrypt", {"raw": todecrypt});
  }

  static Future<void> update(Password password) async {
    db.update(
      PasswordDB.passwordtable,
      password.toUpdateMap(),
      where: "CreationTime = ${password.createdOn}",
    );
    await Update.dbupdated();
  }

  static Future<void> init() async {
    db = await initNativeDB("${await getPath()}/ps.sqlite");
    if (await tableDoesNotExist(passwordtable)) {
      await db.rawQuery("CREATE TABLE ToDecrypt(raw TEXT)");
      await db.rawQuery("""CREATE TABLE $passwordtable (
      CreationTime INTEGER PRIMARY KEY,
      ModificationTime INTEGER,
      password TEXT,
      username TEXT,
      website TEXT
    )""");
    }
    await load();
  }

  static Future<void> load() async {
    PasswordManager.allPasswords = [];

    List<Map> temp = await db.rawQuery("SELECT * FROM ToDecrypt LIMIT 1");
    if (temp.isNotEmpty) {
      todecrypt = temp.first["raw"];
    }
    temp = await db.rawQuery("SELECT * FROM $passwordtable");
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
          CreationTime int PRIMARY KEY
        )
        """);
    }
    await db.insert(deletetable, {"CreationTime": todelete.createdOn});
    await db.delete(passwordtable, where: "CreationTime = ${todelete.createdOn}");
    await Update.dbupdated();
    PasswordManager.allPasswords.remove(todelete);
  }

  static Future<void> add(Password password) async {
    PasswordManager.allPasswords.add(password);
    await db.insert(passwordtable, password.toMap());
    await Update.dbupdated();
  }
}
