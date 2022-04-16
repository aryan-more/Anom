import 'dart:io';

import 'package:anom/Logic/passwordManager/onSave.dart';
import 'package:anom/Logic/permission.dart';
import 'package:anom/Logic/secureio.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/Native/plugin.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
                    child: Text("OK"))
              ],
            ));
  }

  Future<bool> managePermission(BuildContext context) async {
    PermissionStatus status = await externalFileAccess();
    if (status != PermissionStatus.permanentlyDenied || status != PermissionStatus.restricted) {
      status = await requestPermission();
    }
    if (status != PermissionStatus.granted) {
      createDialog(permissionDeniedStatus(status), context);
    }
    return status == PermissionStatus.granted;
  }

  void saveSnackBar(String text, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      "File Exported to $text",
      maxLines: 3,
    )));
  }

  Future<void> export(BuildContext context) async {
    showLoading(context);
    await exportAnd();
    Navigator.of(context).pop();
  }
}
