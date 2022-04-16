import 'package:anom/Logic/db/db.dart';
import 'package:flutter/material.dart';

class PasswordMenu {
  Widget buildList(Function state) {
    return ListView.builder(
        itemCount: PasswordManager.allPasswords.length,
        itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(PasswordManager.allPasswords[index].decryptedwebsite),
                subtitle: Text(PasswordManager.allPasswords[index].decryptedusername),
                tileColor: Colors.grey[900],
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                onTap: () {
                  viewPassword(index, context, state);
                },
              ),
            ));
  }

  void viewPassword(int index, BuildContext context, Function state) {
    Navigator.of(context).pushNamed("/viewPassword", arguments: {"index": index, "refresh": state});
  }

  FloatingActionButton floatingActionButton(BuildContext context, Function state) {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: () {
        Navigator.of(context).pushNamed("/AddOrEditPassword", arguments: {"index": -1, "refresh": state});
      },
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
