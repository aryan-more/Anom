import 'package:anom/Logic/passwordManager/createPassword.dart';
import 'package:anom/Logic/passwordManager/password.dart';
import 'package:anom/UI/Mobile/drawer.dart';
import 'package:flutter/material.dart';

class CreatePasswordMobile extends StatefulWidget {
  const CreatePasswordMobile({Key? key, required this.passwords}) : super(key: key);
  final Passwords passwords;

  @override
  _CreatePasswordMobileState createState() => _CreatePasswordMobileState();
}

class _CreatePasswordMobileState extends State<CreatePasswordMobile> with CreatePassword {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Password"),
      ),
      drawer: DrawerRoute(
        index: 1,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                for (var item in [
                  [0, "Create Password", password],
                  [1, "Confirm Password", confirm]
                ])
                  TextField(
                    decoration: InputDecoration(
                        hintText: item[1] as String,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure[item[0] as int] ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              obscure[item[0] as int] = !obscure[item[0] as int];
                            });
                          },
                        )),
                    controller: item[2] as TextEditingController,
                    obscureText: obscure[item[0] as int],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await validate(context: context, passwords: widget.passwords);
                },
                child: const Text("Create Password"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
