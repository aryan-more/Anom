import 'dart:math';

import 'package:anom/Logic/passwordManager/onSave.dart';
import 'package:anom/Logic/passwordManager/password.dart';
import 'package:anom/Logic/passwordManager/snackbar.dart';
import 'package:flutter/material.dart';

class AddOrEdit {
  TextEditingController website = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController passWord = TextEditingController();
  late List helper;
  final _random = Random();
  bool obscure = true;
  late Function state;

  late int index;
  late Passwords password;

  bool boot = true;
  void onBoot(BuildContext context) {
    if (boot) {
      var temp = ModalRoute.of(context)!.settings.arguments as Map;
      password = temp["passwords"];
      index = temp["index"];
      state = temp["refresh"];
      boot = false;
      helper = [
        [website, "Website/App"],
        [username, "Username/Email"],
        [passWord, "Password"]
      ];
      if (index != -1) {
        website.text = password.passwords[index]["w"];
        username.text = password.passwords[index]["e"];
        passWord.text = password.passwords[index]["p"];
      }
    }
  }

  void obscureEvent() {
    obscure = !obscure;
  }

  void addPassword(BuildContext context) {
    String error = "";
    if (website.text.isEmpty) {
      error = "Website";
    }
    if (username.text.isEmpty) {
      error = error + (error.isNotEmpty ? ", " : "") + "Username";
    }
    if (passWord.text.isEmpty) {
      error = error + (error.isNotEmpty ? ", " : "") + "Password";
    }
    if (error.isNotEmpty) {
      error = "$error cannot be Empty";
    } else if (passWord.text.length < 8) {
      error = "Password Cannot Smaller Than 8 Characters";
    }
    if (error.isEmpty) {
      if (index == -1) {
        password.passwords.add({
          "w": website.text,
          "e": username.text,
          "p": passWord.text,
        });
      } else {
        password.passwords[index] = {
          "w": website.text,
          "e": username.text,
          "p": passWord.text,
        };
      }
      onSave(password, context);
      state(() {});
      Navigator.of(context).pop();
      // pushReplacementNamed("/passwordMenu", arguments: {"passwords": password});
    } else {
      showSnackBar(context: context, error: error);
    }
  }

  void generatePassword() {
    int length = _random.nextInt(8) + 8;
    String text;
    List<String> list = [];
    List<String> character = ["!\"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz", "0123456789"];
    for (text in character) {
      for (int i = 0; i < (length / 4).round(); i++) {
        list.add(text[_random.nextInt(text.length)]);
      }
    }
    while (list.length < length) {
      text = character[_random.nextInt(character.length)];
      list.add(text[_random.nextInt(text.length)]);
    }

    String guest = "";
    while (list.isNotEmpty) {
      guest = guest + list.removeAt(_random.nextInt(list.length));
    }
    passWord.text = guest;
  }
}
