import 'dart:convert';
import 'dart:typed_data';

import 'package:anom/Logic/secureio.dart';

class Password {
  List passwords = [];
  late List<int> hashedPassword;
  late Uint8List _bin;

  Future<void> load() async {
    _bin = await readBin(filename: "passwords");
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
    print((await getFile("passwords")).path);
    return (await (await getFile("passwords")).exists());
  }

  Future<void> dump() async {
    _bin = encrypt(raw: jsonEncode(passwords), hashedPassword: hashedPassword);
    await writeBin(filename: "passwords", bits: _bin);
  }
}
