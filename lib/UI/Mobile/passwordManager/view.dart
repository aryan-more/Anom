import 'package:anom/Logic/passwordManager/viewPassword.dart';
import 'package:flutter/material.dart';

class ViewPasswordMobile extends StatefulWidget {
  const ViewPasswordMobile({Key? key}) : super(key: key);

  @override
  _ViewPasswordMobileState createState() => _ViewPasswordMobileState();
}

class _ViewPasswordMobileState extends State<ViewPasswordMobile> with ViewPassword {
  @override
  void dispose() {
    super.dispose();
    password.forgetDecrypted();
  }

  @override
  Widget build(BuildContext context) {
    onBoot(context);
    return Scaffold(
      appBar: AppBar(title: Text(password.passwords[index]["w"])),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [
              for (var item in [
                ["e", "Usename/Email"],
                ["p", "Password"]
              ])
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item[1],
                      style: const TextStyle(fontSize: 22),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item[0] == "p"
                            ? obscure
                                ? "•" * 10
                                : password.passwords[index][item[0]]
                            : password.passwords[index][item[0]]),
                        if (item[0] == "w")
                          const SizedBox()
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (item[0] == "p")
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscure = !obscure;
                                      });
                                    },
                                    icon: Icon(
                                      obscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                                      color: Colors.blue,
                                    )),
                              IconButton(
                                  onPressed: () {
                                    copy(item[0]);
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
                ),
            ]),
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
