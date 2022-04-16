import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/passwordManager/viewPassword.dart';
import 'package:flutter/material.dart';

class ViewPasswordMobile extends StatefulWidget {
  const ViewPasswordMobile({Key? key}) : super(key: key);

  @override
  _ViewPasswordMobileState createState() => _ViewPasswordMobileState();
}

class _ViewPasswordMobileState extends State<ViewPasswordMobile> with ViewPassword {
  @override
  Widget build(BuildContext context) {
    onBoot(context);
    return Scaffold(
      appBar: AppBar(title: Text(PasswordManager.allPasswords[index].decryptedwebsite)),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                getColumn("Usename/Email", PasswordManager.allPasswords[index].decryptedusername, ShowDetails.username, () {
                  setState(() {});
                }),
                getColumn("Password", PasswordManager.allPasswords[index].decryptedpassword, ShowDetails.password, () {
                  setState(() {});
                }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      delete(context);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text("Delete"),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      edit(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
