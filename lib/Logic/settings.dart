import 'dart:io';

import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/db/drive.dart';
import 'package:anom/Logic/db/synchronize.dart';
import 'package:anom/Logic/passwordManager/onSave.dart';
import 'package:anom/Logic/permission.dart';
import 'package:anom/Logic/secureio.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/Native/plugin.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class SettingsMixMin {
  void addCustomUrls(CustomUrlObj customUrls, BuildContext context) {
    TextEditingController controller = TextEditingController(text: customUrls.tostring());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("One url per line"),
        content: SizedBox(
          height: 200,
          child: TextField(
            controller: controller,
            maxLines: 500,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                showLoading(context);
                await customUrls.updateUrls(controller.text);
                Navigator.of(context).pop();
              },
              child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Text(
                      "Submit",
                      textAlign: TextAlign.center,
                    ),
                  )))
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void createDialog(String text, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(text),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const SizedBox(
                        width: double.infinity,
                        child: Text(
                          "OK",
                          textAlign: TextAlign.center,
                        )))
              ],
            ));
  }

  void _showInvalidPassword(BuildContext context, String text, [Function? fun]) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                text,
                maxLines: 2,
              ),
              actions: [
                TextButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (fun != null) {
                        fun();
                      }
                    },
                    child: const SizedBox(
                        width: double.infinity,
                        child: Text(
                          "OK",
                          textAlign: TextAlign.center,
                        ))),
              ],
            ));
  }

  Future<bool> managePermission(BuildContext context) async {
    if (Platform.isWindows) {
      return true;
    }
    PermissionStatus status = await externalFileAccess();
    if (status != PermissionStatus.permanentlyDenied || status != PermissionStatus.restricted) {
      status = await requestPermission();
    }
    if (status != PermissionStatus.granted) {
      createDialog(permissionDeniedStatus(status), context);
    }
    return status == PermissionStatus.granted;
  }

  void showSnackBar(String text, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        maxLines: 2,
      ),
      backgroundColor: Colors.blue,
    ));
  }

  Future<void> export(BuildContext context) async {
    showLoading(context);
    await exportPassword();
    showSnackBar("Password.anomps saved at documents folder", context);
    Navigator.of(context).pop();
  }

  Future<void> import(BuildContext context, Function ondone) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, allowedExtensions: ["anomps"]);
    if (result != null) {
      showLoading(context);
      File file = File(result.files.single.path!);
      await writeBin(filename: "updateDB", bits: await file.readAsBytes());
      if (await update(context, ondone)) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> update(BuildContext context, Function ondone) async {
    SynchronizeDB db = SynchronizeDB();
    if (!await db.init()) {
      showSnackBar("Invalid File", context);
      return true;
    }
    if (await db.updateRequired()) {
      if (await db.checkPasswordMatch()) {
        await db.update(ondone);
      } else {
        Navigator.of(context).pop();
        await changePassword(context, true, db, true, ondone);
        return false;
      }
    }
    return true;
  }

  Future<void> changePassword(BuildContext context, bool migrate, SynchronizeDB db, bool local, Function ondone) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          TextEditingController newcontroller = TextEditingController();
          bool newobscure = true;
          TextEditingController oldcontroller = TextEditingController();
          bool oldobscure = true;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                title: Text(migrate ? "Password Change Detected,\n Enter Changed Password" : "Change Password", maxLines: 4),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: oldcontroller,
                      obscureText: oldobscure,
                      decoration: InputDecoration(
                        hintText: migrate ? "Old Password" : "Local Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            oldobscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              oldobscure = !oldobscure;
                            });
                          },
                        ),
                      ),
                    ),
                    TextField(
                      controller: newcontroller,
                      obscureText: newobscure,
                      decoration: InputDecoration(
                        hintText: migrate
                            ? local
                                ? "Import Save Password"
                                : "Cloudsave Password"
                            : "New Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            newobscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              newobscure = !newobscure;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextButton(
                        onPressed: () async {
                          if (!PasswordManager.checkPassword(oldcontroller.text)) {
                            _showInvalidPassword(context, "Invalid old Password");
                            return;
                          }
                          if (migrate) {
                            if (!db.checkPassword(newcontroller.text)) {
                              _showInvalidPassword(context, "Invalid New Password");
                              return;
                            }
                            Navigator.of(context).pop();
                            showLoading(context);
                            await db.updatePasswordChanged(ondone);
                            Navigator.of(context).pop();
                            return;
                          } else {
                            if (newcontroller.text == "") {
                              _showInvalidPassword(context, "New Password Can't Be Empty");
                              return;
                            }
                            showLoading(context);
                            await PasswordDB.changePassword(hashSha256(newcontroller.text));
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                          PasswordManager.forget();
                        },
                        child: const SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Submit",
                              textAlign: TextAlign.center,
                            ))),
                    const SizedBox(
                      height: 12,
                    ),
                    TextButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ));
          });
        });
  }

  Future<bool> checkInternet(BuildContext context) async {
    if (!await InternetConnectionChecker().hasConnection) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No Internet Connection"),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    return true;
  }

  Future<void> login(BuildContext context) async {
    if (await checkInternet(context)) {
      GoogleDrive drive = GoogleDrive();
      if (!await drive.logIn()) {
        _showInvalidPassword(context, "Log In Failed");
      }
    }
  }

  Future<void> cloudSync(BuildContext context) async {
    if (await checkInternet(context)) {
      GoogleDrive drive = GoogleDrive();
      showLoading(context);
      if (await drive.loadtoken()) {
        Navigator.of(context).pop();
        _showInvalidPassword(context, "Credentials Expired!");
        return;
      }
      try {
        if (await drive.download()) {
          if (await update(context, () async {
            if (Update.uploadrequired) {
              try {
                showLoading(context);
                await drive.upload();
                Navigator.of(context).pop();
              } on DriveError catch (_) {
                _showInvalidPassword(context, _.error, () {
                  Navigator.of(context).pop();
                });
              } catch (_) {
                _showInvalidPassword(context, "Something Went Wrong", () {
                  Navigator.of(context).pop();
                });
              }
            }
          })) {
            Navigator.of(context).pop();
          }
        } else if (Update.uploadrequired) {
          showLoading(context);
          await drive.upload();
          Navigator.of(context).pop();
        }
      } on DriveError catch (_) {
        _showInvalidPassword(context, _.error);
      } catch (_) {
        Navigator.of(context).pop();
        _showInvalidPassword(context, "Something Went Wrong");
      }
    }
  }
}
