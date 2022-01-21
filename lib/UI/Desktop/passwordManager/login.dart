import 'package:anom/Logic/passwordManager/login.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:anom/UI/Desktop/navigationrail.dart';
import 'package:flutter/material.dart';

class LoginPasswordManagerDesktop extends StatefulWidget {
  const LoginPasswordManagerDesktop({Key? key}) : super(key: key);

  @override
  _LoginPasswordManagerDesktopState createState() => _LoginPasswordManagerDesktopState();
}

class _LoginPasswordManagerDesktopState extends State<LoginPasswordManagerDesktop> with LoginLogic, GetGeometry {
  @override
  Widget build(BuildContext context) {
    getGeometry(context);
    loadPassword(context);
    return Scaffold(
      appBar: bar(),
      body: Row(
        children: [
          NavigationRouteRail(index: 1),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(top: height * 0.25, bottom: height * 0.35, left: width * 0.26, right: width * 0.30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.grey[900], borderRadius: const BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                          ),
                        ),
                        controller: controller,
                        obscureText: obscure,
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                    onPressed: () {
                      login(context: context);
                    },
                    label: Text("Login"),
                    icon: Icon(Icons.arrow_right))
              ],
            ),
          ))
        ],
      ),
    );
  }
}
