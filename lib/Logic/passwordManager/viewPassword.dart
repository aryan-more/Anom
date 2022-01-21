import 'package:anom/Logic/passwordManager/onsSave.dart';
import 'package:anom/Logic/passwordManager/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewPassword {
  bool boot = true;
  late Function state;
  bool obscure = true;

  late int index;
  late Password password;
  void onBoot(BuildContext context) {
    if (boot) {
      var temp = ModalRoute.of(context)!.settings.arguments as Map;
      password = temp["passwords"];
      index = temp["index"];
      state = temp["refresh"];
      boot = false;
    }
  }

  void copy(String key) {
    Clipboard.setData(ClipboardData(text: password.passwords[index][key]));
  }

  void edit(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed("/AddOrEditPassword", arguments: {"passwords": password, "index": index, "refresh": state});
  }

  void delete(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              title: Text("Confirm Delete"),
              content: TextButton(
                onPressed: () async {
                  password.passwords.removeAt(index);
                  await onSave(password, context);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  state(() {});
                },
                // icon: const Icon(Icons.delete_outline_rounded),
                child: const Text("Delete"),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
              ),
            ));
  }
}
