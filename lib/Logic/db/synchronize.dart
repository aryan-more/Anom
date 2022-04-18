import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/db/drive.dart';
import 'package:anom/Logic/db/native.dart';
import 'package:anom/Logic/secureio.dart';
import 'package:sqflite/sqflite.dart';

class SynchronizeDB {
  late Database database;
  late String to_decrypt;
  late List<int> hashed;
  Future<bool> init() async {
    try {
      database = await initNativeDB("${await getPath()}/updateDB");
      to_decrypt = (await database.rawQuery("SELECT * FROM ToDecrypt LIMIT 1")).first["raw"] as String;

      return true;
    } catch (_) {
      print(_);
    }
    return false;
  }

  Future<bool> checkPasswordMatch() async {
    if (PasswordDB.saveExist) {
      return PasswordDB.todecrypt! == to_decrypt;
    }
    return true;
  }

  bool checkPassword(String raw) {
    try {
      hashed = hashSha256(raw);
      decrypt64(bin: to_decrypt, hashedPassword: hashed);
      return true;
    } catch (_) {}
    return false;
  }

  Future<void> performDelete() async {
    var temp = await database.rawQuery("SELECT * FROM ${PasswordDB.deletetable}");
    List<int> todelete = [];
    for (var item in temp) {
      todelete.add(item["CreationTime"] as int);
    }
    for (var item in List.from(PasswordManager.allPasswords)) {
      if (todelete.contains(item.createdOn)) {
        await PasswordDB.delete(item);
      }
    }
  }

  Future<void> performUpdate() async {
    var temp = await database.rawQuery("SELECT * FROM ${PasswordDB.passwordtable}");
    int index;
    bool update = false;
    var tempquery = await PasswordDB.db.rawQuery("SELECT * FROM ${PasswordDB.deletetable}");
    List<int> deleted = [];
    for (var item in tempquery) {
      deleted.add(item["CreationTime"] as int);
    }
    for (var item in temp) {
      index = PasswordManager.allPasswords.indexWhere((element) => element.createdOn == item["CreationTime"]);
      if (index == -1) {
        if (deleted.contains(item["CreationTime"])) {
          PasswordDB.add(Password.fromMap(item));
          update = true;
        }
        continue;
      }
      if (PasswordManager.allPasswords[index].modifiedOn < (item["ModificationTime"] as int)) {
        await PasswordManager.allPasswords[index].copy(item);
      } else if (PasswordManager.allPasswords[index].modifiedOn > (item["ModificationTime"] as int)) {
        update = true;
      }
    }
    Update.uploadrequired = update;
    await Update.save();
  }

  Future<void> passwordChangedUpdate() async {
    List<Password> cloud = [];
    bool update = false;
    var temp = await database.rawQuery("SELECT * FROM ${PasswordDB.passwordtable}");
    var tempquery = await PasswordDB.db.rawQuery("SELECT * FROM ${PasswordDB.deletetable}");
    List<int> deleted = [];
    for (var item in tempquery) {
      deleted.add(item["CreationTime"] as int);
    }
    for (var item in temp) {
      cloud.add(Password.fromMap(item));
    }
    List<Password> copy = List.from(PasswordManager.allPasswords);
    List<Password> migrate = [];
    List<Password> replace = [];
    List<Password> toadd = [];
    int index;
    for (var item in cloud) {
      index = copy.indexWhere((element) => element.createdOn == item.createdOn);
      if (index != -1) {
        if (copy[index].modifiedOn <= item.modifiedOn) {
          int replaceIndex = PasswordManager.allPasswords.indexWhere((element) => element.createdOn == item.createdOn);
          PasswordManager.allPasswords[replaceIndex] = item;
          replace.add(item);
        } else {
          migrate.add(copy[index]);
          Update.uploadrequired = true;
        }
        copy.removeAt(index);
      } else if (!deleted.contains(item.createdOn)) {
        toadd.add(item);
      } else {
        Update.uploadrequired = true;
      }
    }
    for (var item in toadd) {
      PasswordDB.add(item);
    }
    for (var item in replace) {
      PasswordDB.update(item);
    }
    if (copy.isNotEmpty) {
      migrate.insertAll(0, copy);
      Update.uploadrequired = true;
    }
    for (var item in migrate) {
      item.migrate(hashed);
    }
    PasswordDB.todecrypt = to_decrypt;
    await PasswordDB.db.update("ToDecrypt", {"raw": to_decrypt});
    PasswordManager.forget();
    await PasswordDB.load();
    Update.uploadrequired = update;
    await Update.save();
  }

  Future<bool> updateRequired() async {
    if (PasswordManager.allPasswords.isEmpty) {
      await PasswordDB.db.close();

      await (await getFile("updateDB")).copy(("${await getPath()}/ps.sqlite"));
      await cleanup();
      await PasswordDB.init();
      await PasswordDB.load();
      return false;
    }
    return true;
  }

  Future<void> cleanup() async {
    await database.close();
    await (await getFile("updateDB")).delete();
  }

  Future<void> update(Function ondone) async {
    await performDelete();
    await performUpdate();
    await cleanup();
    if (Update.uploadrequired) {
      await ondone();
    }
  }

  Future<void> updatePasswordChanged(Function ondone) async {
    await performDelete();
    await passwordChangedUpdate();
    await cleanup();
    if (Update.uploadrequired) {
      await ondone();
    }
  }
}
