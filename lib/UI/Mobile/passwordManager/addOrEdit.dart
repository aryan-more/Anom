import 'package:anom/Logic/passwordManager/addOrEdit.dart';
import 'package:flutter/material.dart';

class AddOrEditPasswordMobile extends StatefulWidget {
  const AddOrEditPasswordMobile({Key? key}) : super(key: key);

  @override
  _AddOrEditPasswordMobileState createState() => _AddOrEditPasswordMobileState();
}

class _AddOrEditPasswordMobileState extends State<AddOrEditPasswordMobile> with AddOrEdit {
  @override
  Widget build(BuildContext context) {
    onBoot(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var item in helper)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: item[1] == "Password" ? const EdgeInsets.only(top: 2, bottom: 10, left: 10, right: 10) : const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: const BorderRadius.all(Radius.circular(15))),
                      child: TextField(
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
                                : const SizedBox()),
                        obscureText: item[1] == "Password" ? obscure : false,
                      ),
                    ),
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
    );
  }
}
