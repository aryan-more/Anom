import 'package:anom/Logic/db/db.dart';
import 'package:anom/Logic/passwordManager/viewPassword.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:flutter/material.dart';

class ViewPasswordDesktop extends StatefulWidget {
  const ViewPasswordDesktop({Key? key}) : super(key: key);

  @override
  _ViewPasswordDesktopState createState() => _ViewPasswordDesktopState();
}

class _ViewPasswordDesktopState extends State<ViewPasswordDesktop> with ViewPassword, GetGeometry {
  @override
  Widget build(BuildContext context) {
    getGeometry(context);
    onBoot(context);
    return Scaffold(
      appBar: bar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.keyboard_arrow_left_outlined,
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: height * 0.22, bottom: height * 0.28, left: width * 0.22, right: width * 0.28),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: const BorderRadius.all(Radius.circular(15))),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getColumn("Website/App", PasswordManager.allPasswords[index].decryptedwebsite, ShowDetails.web, () {
                      setState(() {});
                    }),
                    getColumn("Usename/Email", PasswordManager.allPasswords[index].decryptedusername, ShowDetails.username, () {
                      setState(() {});
                    }),
                    getColumn("Password", PasswordManager.allPasswords[index].decryptedpassword, ShowDetails.password, () {
                      setState(() {});
                    }),
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
            ),
          )
        ],
      ),
    );
  }
}
