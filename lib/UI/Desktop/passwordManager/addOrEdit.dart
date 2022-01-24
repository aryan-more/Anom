import 'package:anom/Logic/passwordManager/addOrEdit.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:flutter/material.dart';

class AddOrEditPasswordDesktop extends StatefulWidget {
  const AddOrEditPasswordDesktop({Key? key}) : super(key: key);

  @override
  _AddOrEditPasswordDesktopState createState() => _AddOrEditPasswordDesktopState();
}

class _AddOrEditPasswordDesktopState extends State<AddOrEditPasswordDesktop> with AddOrEdit, GetGeometry {
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
              padding: EdgeInsets.only(top: height * 0.18, bottom: height * 0.20, left: width * 0.22, right: width * 0.28),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: const BorderRadius.all(Radius.circular(15))),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        for (var item in helper)
                          TextField(
                            controller: item[0],
                            decoration: InputDecoration(
                                hintText: "Enter ${item[1]}",
                                suffix: item[1] == "Password"
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscureEvent();
                                          });
                                        },
                                        icon: Icon(
                                          obscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                                          color: Colors.blue,
                                        ))
                                    : null),
                            obscureText: item[1] == "Password" ? obscure : false,
                          ),
                        TextButton.icon(
                          style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.blue), backgroundColor: MaterialStateProperty.all(Colors.transparent)),
                          onPressed: () {
                            setState(() {
                              generatePassword();
                            });
                          },
                          icon: const Icon(
                            Icons.replay,
                          ),
                          label: const Text(
                            "Generate Password",
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      child: TextButton(
                        onPressed: () {
                          addPassword(context);
                        },
                        child: const Text("Submit"),
                      ),
                      width: double.infinity,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
