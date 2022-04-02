import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';

List<int> hashSha256(String raw) {
  return sha256.convert(utf8.encode(raw)).bytes;
}

IV getIV(List<int> raw) {
  return IV((Uint8List.fromList(md5.convert(raw).bytes)));
}

Uint8List encrypt({required String raw, required List<int> hashedPassword}) {
  Key key = Key(Uint8List.fromList(hashedPassword));
  Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(raw, iv: getIV(hashedPassword));
  return encrypted.bytes;
}

String decrypt({required Uint8List bin, required List<int> hashedPassword}) {
  Key key = Key(Uint8List.fromList(hashedPassword));
  Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  return encrypter.decrypt(Encrypted(bin), iv: getIV(hashedPassword));
}

Future<String> getPath() async {
  var path = await getApplicationDocumentsDirectory();
  return "${path.path}/Anom";
}

Future<void> exportPasswords() async {
  var path = await getExternalStorageDirectories(type: StorageDirectory.documents);
  File file = File("${path!.first.path}/passwords.anomps");
  print(path.first.path);
}

Future<File> getFile(String path) async {
  return File((await getPath()) + "/$path");
}

Future<Uint8List> readBin({required String filename}) async {
  File file = File((await getPath()) + "/$filename");
  return file.readAsBytes();
}

Future<void> writeBin({required String filename, required Uint8List bits}) async {
  File file = File((await getPath()) + "/$filename");
  await file.writeAsBytes(bits);
}

Future<String> read({required String filename}) async {
  File file = File((await getPath()) + "/$filename");
  return file.readAsString();
}

Future<void> write({required String filename, required String rawdata}) async {
  File file = File((await getPath()) + "/$filename");
  await file.writeAsString(rawdata);
}
