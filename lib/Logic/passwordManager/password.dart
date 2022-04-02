import 'dart:convert';
import 'dart:typed_data';

import 'package:anom/Logic/secureio.dart';

class Passwords {
  List passwords = [];
  late List<int> hashedPassword;
  late Uint8List _bin;
  late bool saveExist;

  Future<void> load() async {
    _bin = await readBin(filename: "passwords");
  }

  void forgetDecrypted() {
    passwords = [];
    hashedPassword = [];
  }

  bool checkPassword(String password) {
    try {
      hashedPassword = hashSha256(password);
      passwords = jsonDecode(decrypt(bin: _bin, hashedPassword: hashedPassword));
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> exist() async {
    saveExist = (await (await getFile("passwords")).exists());
    return saveExist;
  }

  Future<void> dump() async {
    _bin = encrypt(raw: jsonEncode(passwords), hashedPassword: hashedPassword);
    await writeBin(filename: "passwords", bits: _bin);
  }
}
