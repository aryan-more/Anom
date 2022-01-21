import 'package:anom/Logic/passwordManager/createPassword.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:anom/UI/Desktop/navigationrail.dart';
import 'package:flutter/material.dart';

class CreatePasswordDesktop extends StatefulWidget {
  const CreatePasswordDesktop({Key? key}) : super(key: key);

  @override
  _CreatePasswordDesktopState createState() => _CreatePasswordDesktopState();
}

class _CreatePasswordDesktopState extends State<CreatePasswordDesktop> with GetGeometry, CreatePassword {
  @override
  Widget build(BuildContext context) {
    getGeometry(context);
    return Scaffold(
      appBar: bar(),
      body: Row(
        children: [
          const NavigationRouteRail(index: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: height * 0.20, bottom: height * 0.30, left: width * 0.26, right: width * 0.30),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.grey[900], borderRadius: const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                      TextButton(
                        onPressed: () async {
                          await validate(context: context);
                        },
                        child: const Text("Create Password"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
