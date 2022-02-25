import 'dart:io';

import 'package:anom/UI/Desktop/passwordManager/addOrEdit.dart';
import 'package:anom/UI/Desktop/passwordManager/createPassword.dart';
import 'package:anom/UI/Desktop/passwordManager/login.dart';
import 'package:anom/UI/Desktop/passwordManager/passwordMenu.dart';
import 'package:anom/UI/Desktop/passwordManager/passwordloading.dart';
import 'package:anom/UI/Desktop/passwordManager/view.dart';
import 'package:anom/UI/Desktop/privacy/privacyCenter.dart';
import 'package:anom/UI/Mobile/passwordManager/addOrEdit.dart';
import 'package:anom/UI/Mobile/passwordManager/createPassword.dart';
import 'package:anom/UI/Mobile/passwordManager/login.dart';
import 'package:anom/UI/Mobile/passwordManager/passwordMenu.dart';
import 'package:anom/UI/Mobile/passwordManager/passwordloading.dart';
import 'package:anom/UI/Mobile/passwordManager/view.dart';
import 'package:anom/UI/Mobile/privacy/privacyCenter.dart';
import 'package:anom/UI/boot.dart';
import 'package:anom/UI/platformNotSupported.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
  bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  bool isMobile = Platform.isAndroid || Platform.isIOS;
  bool minSupport = isDesktop || isMobile;

  runApp(MaterialApp(
    routes: {
      "/": (context) => minSupport ? const Boot() : const PlatformNotSupported(),
      "/loadPasswords": (context) => isMobile ? const LoadingPasswordManagerMobile() : const LoadingPasswordManagerDesktop(),
      "/createPassword": (context) => isMobile ? const CreatePasswordMobile() : const CreatePasswordDesktop(),
      "/loginPassword": (context) => isMobile ? const LoginPasswordManagerMobile() : const LoginPasswordManagerDesktop(),
      "/passwordMenu": (context) => isMobile ? const PasswordMangerMenuMobile() : const PasswordMangerMenuDesktop(),
      "/AddOrEditPassword": (context) => isMobile ? const AddOrEditPasswordMobile() : const AddOrEditPasswordDesktop(),
      "/viewPassword": (context) => isMobile ? const ViewPasswordMobile() : const ViewPasswordDesktop(),
      "/privacyCenter": (context) => isMobile ? PrivacyCenterMobile() : PrivacyCenterDesktop(),
    },
    theme: ThemeData(
        backgroundColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(border: UnderlineInputBorder()),
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          color: Colors.black,
        ),
        textTheme: const TextTheme(bodyText2: TextStyle(overflow: TextOverflow.fade)),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            textStyle: MaterialStateProperty.all(const TextStyle(
              fontSize: 22,
            )),
          ),
        ),
        scaffoldBackgroundColor: Colors.black,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.red,
        )),
  ));
  if (isDesktop) {
    doWhenWindowReady(() {
      final win = appWindow;
      const initialSize = Size(800, 600);
      win.minSize = initialSize;
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = "Anom";
      win.show();
    });
  }
}
