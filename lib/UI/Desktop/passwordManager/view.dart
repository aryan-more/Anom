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
                    for (var item in [
                      ["w", "Website/App"],
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
                        SizedBox(
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
