import 'dart:convert';
import 'dart:typed_data';

import 'package:anom/Logic/secureio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis/drive/v3.dart' as cloud;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

// credentials.dart Not Included in the source code to avoid api keys abuse
import 'package:anom/Logic/db/credentials.dart';

var _client = auth.ClientId(clientID, clientSecret);

final scope = [cloud.DriveApi.driveAppdataScope];

class Update {
  static late bool uploadrequired;
  static DateTime? lastupdate;

  static Future<void> save() async {
    await write(filename: "updateconfig.json", rawdata: jsonEncode({"uploadrequired": uploadrequired, "lastupdate": (lastupdate == null ? "" : lastupdate!.toIso8601String())}));
  }

  static Future<void> load() async {
    if (await fileExist("updateconfig.json")) {
      Map temp = jsonDecode(await read(filename: "updateconfig.json"));
      uploadrequired = temp["update"] ?? false;
      lastupdate = temp["lastupdate"] == "" ? null : DateTime.parse(temp["lastupdate"]);
      return;
    }
    uploadrequired = false;
  }

  static Future<void> dbupdated() async {
    if (!uploadrequired) {
      uploadrequired = true;
      await save();
    }
  }
}

class GoogleDriveToken {
  static String? data;
  static String? type;
  static DateTime? expiry;
  static String? refreshToken;
  static bool saveExist = false;

  static Future<void> init() async {
    const secure = FlutterSecureStorage();
    saveExist = await secure.containsKey(key: "token");
  }

  static void forget() {
    data = null;
    type = null;
    expiry = null;
    refreshToken = null;
  }

  static Map toJson() {
    return {
      "data": data,
      "type": type,
      "expiry": expiry!.toIso8601String(),
      "refreshToken": refreshToken,
    };
  }

  static Future<void> saveConfig() async {
    const secure = FlutterSecureStorage();
    secure.write(key: "token", value: jsonEncode(toJson()));
    saveExist = true;
  }

  static Future<void> loadConfig() async {
    const secure = FlutterSecureStorage();
    String? raw = await secure.read(key: "token");

    Map temp = jsonDecode(raw!);
    data = temp["data"];
    type = temp["type"];
    expiry = DateTime.parse(temp["expiry"]);
    refreshToken = temp["refreshToken"];
  }

  static Future<void> deleteToken() async {
    const secure = FlutterSecureStorage();
    secure.delete(key: "token");
    forget();
    saveExist = false;
  }
}

class DriveError extends Error {
  final String error;
  DriveError(this.error);
}

class GoogleDrive {
  late cloud.DriveApi? drive;

  Future<bool> logIn() async {
    try {
      auth.AutoRefreshingAuthClient authclient = await auth.clientViaUserConsent(_client, scope, (uri) {
        launch(uri);
      });
      drive = cloud.DriveApi(authclient);
      GoogleDriveToken.data = authclient.credentials.accessToken.data;

      GoogleDriveToken.type = authclient.credentials.accessToken.type;
      GoogleDriveToken.expiry = authclient.credentials.accessToken.expiry;
      GoogleDriveToken.refreshToken = authclient.credentials.refreshToken!;
      GoogleDriveToken.saveConfig();
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<bool> loadtoken() async {
    await GoogleDriveToken.loadConfig();
    try {
      var token = auth.AccessToken(
        GoogleDriveToken.type!,
        GoogleDriveToken.data!,
        GoogleDriveToken.expiry!,
      );
      auth.AccessCredentials newcred = await auth.refreshCredentials(
          _client,
          auth.AccessCredentials(
            token,
            GoogleDriveToken.refreshToken!,
            scope,
          ),
          http.Client());

      drive = cloud.DriveApi(auth.authenticatedClient(http.Client(), newcred));
      return true;
    } catch (e) {
      await GoogleDriveToken.deleteToken();
      return false;
    }
  }

  Future<bool> download() async {
    try {
      var files = await drive!.files.list(spaces: "appDataFolder");
      if (files.files!.isEmpty) {
        return false;
      } else {
        try {
          if (Update.lastupdate != null && files.files!.first.modifiedTime != Update.lastupdate) {
            cloud.Media rawData = await drive!.files.get(files.files!.first.id!, downloadOptions: cloud.DownloadOptions.fullMedia) as cloud.Media;
            List<List<int>> rawdata = await rawData.stream.toList();
            List<int> data = [];
            for (var item in rawdata) {
              data.insertAll(data.length, item);
            }
            await writeBin(filename: "updateDB", bits: Uint8List.fromList(data));
            Update.lastupdate = files.files!.first.modifiedTime;
            await Update.save();
          }
          return true;
        } catch (_) {
          DriveError("Download Failed");
        }
      }
    } catch (_) {
      throw DriveError("Download Check Failed");
    }
    return false;
  }

  Future<void> upload() async {
    try {
      var file = await getFile("ps.sqlite");
      var files = await drive!.files.list(spaces: "appDataFolder");
      if (files.files!.isNotEmpty) {
        Update.lastupdate = (await drive!.files.update(cloud.File()..name = "cloudsave", files.files!.first.id!, uploadMedia: cloud.Media(file.openRead(), file.lengthSync()))).modifiedTime;
      } else {
        Update.lastupdate = (await drive!.files.create(
                cloud.File()
                  ..name = "cloudsave"
                  ..parents = ['appDataFolder'],
                uploadMedia: cloud.Media(file.openRead(), file.lengthSync())))
            .createdTime;
      }
      Update.uploadrequired = false;
      await Update.save();
    } catch (_) {
      DriveError("Upload Failed");
    }
  }
}
