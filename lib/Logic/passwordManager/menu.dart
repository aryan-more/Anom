import 'package:anom/Logic/passwordManager/password.dart';
import 'package:flutter/material.dart';

class PasswordMenu {
  late Password password;
  bool boot = true;
  void loadPassword(BuildContext context) {
    if (boot) {
      var temp = ModalRoute.of(context)!.settings.arguments as Map;
      password = temp["passwords"];
      boot = false;
    }
  }

  Widget buildList(Function state) {
    return ListView.builder(
        itemCount: password.passwords.length,
        itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(password.passwords[index]["w"]),
                subtitle: Text(password.passwords[index]["e"]),
                tileColor: Colors.grey[900],
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                onTap: () {
                  viewPassword(index, context, state);
                },
              ),
            ));
  }

  void viewPassword(int index, BuildContext context, Function state) {
    Navigator.of(context).pushNamed("/viewPassword", arguments: {"passwords": password, "index": index, "refresh": state});
  }

  FloatingActionButton floatingActionButton(BuildContext context, Function state) {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: () {
        Navigator.of(context).pushNamed("/AddOrEditPassword", arguments: {"passwords": password, "index": -1, "refresh": state});
      },
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
