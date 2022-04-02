import 'package:anom/Logic/passwordManager/login.dart';
import 'package:anom/UI/Mobile/drawer.dart';
import 'package:anom/Logic/passwordManager/password.dart';
import 'package:flutter/material.dart';

class LoginPasswordManagerMobile extends StatefulWidget {
  const LoginPasswordManagerMobile({Key? key, required this.passwords}) : super(key: key);
  final Passwords passwords;

  @override
  _LoginPasswordManagerMobileState createState() => _LoginPasswordManagerMobileState();
}

class _LoginPasswordManagerMobileState extends State<LoginPasswordManagerMobile> with LoginLogic {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Password Manager"),
      ),
      drawer: DrawerRoute(
        index: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: const BorderRadius.all(Radius.circular(15))),
              child: TextField(
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
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                  onPressed: () {
                    login(context: context, password: widget.passwords);
                  },
                  label: const Text("Login"),
                  icon: const Icon(Icons.arrow_right)),
            )
          ],
        ),
      ),
    );
  }
}
