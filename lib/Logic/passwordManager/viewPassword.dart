import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/passwordManager/onSave.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewPassword {
  bool boot = true;
  late Function state;
  bool obscure = true;

  late int index;
  void onBoot(BuildContext context) {
    if (boot) {
      var temp = ModalRoute.of(context)!.settings.arguments as Map;
      index = temp["index"];
      state = temp["refresh"];
      boot = false;
    }
  }

  Widget getColumn(String title, String value, ShowDetails show, Function state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(show == ShowDetails.password
                ? obscure
                    ? "•" * 10
                    : value
                : value),
            if (show == ShowDetails.web)
              const SizedBox()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (show == ShowDetails.password)
                    IconButton(
                        onPressed: () {
                          obscure = !obscure;
                          state();
                        },
                        icon: Icon(
                          obscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                          color: Colors.blue,
                        )),
                  IconButton(
                      onPressed: () {
                        copy(value);
                      },
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.blue,
                      )),
                ],
              )
          ],
        )
      ],
    );
  }

  void copy(String key) {
    Clipboard.setData(ClipboardData(text: key));
  }

  void edit(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed("/AddOrEditPassword", arguments: {"index": index, "refresh": state});
  }

  void delete(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              title: const Text("Confirm Delete"),
              content: TextButton(
                onPressed: () async {
                  showLoading(context);
                  await PasswordDB.delete(PasswordManager.allPasswords[index]);
                  Navigator.of(context).pop();
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
