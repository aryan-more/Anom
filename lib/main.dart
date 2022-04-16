import 'dart:io';

import 'package:anom/Logic/db/db.dart';
import 'package:anom/Native/blockSubjects.dart';
import 'package:anom/UI/Desktop/passwordManager/addOrEdit.dart';
import 'package:anom/UI/Desktop/passwordManager/createPassword.dart';
import 'package:anom/UI/Desktop/passwordManager/login.dart';
import 'package:anom/UI/Desktop/passwordManager/passwordMenu.dart';
import 'package:anom/UI/Desktop/passwordManager/view.dart';
import 'package:anom/UI/Desktop/privacy/privacyCenter.dart';
import 'package:anom/UI/Desktop/settings.dart';
import 'package:anom/UI/Mobile/passwordManager/addOrEdit.dart';
import 'package:anom/UI/Mobile/passwordManager/createPassword.dart';
import 'package:anom/UI/Mobile/passwordManager/login.dart';
import 'package:anom/UI/Mobile/passwordManager/passwordMenu.dart';
import 'package:anom/UI/Mobile/passwordManager/view.dart';
import 'package:anom/UI/Mobile/privacy/privacyCenter.dart';
import 'package:anom/UI/Mobile/settings.dart';
import 'package:anom/UI/boot.dart';
import 'package:anom/UI/platformNotSupported.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PrivacyCenter center = PrivacyCenter();
  await PasswordManager.init();
  await center.getSavedPrefernce();

  bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  bool isMobile = Platform.isAndroid || Platform.isIOS;
  bool minSupport = isDesktop || isMobile;

  runApp(
    MaterialApp(
      routes: {
        "/": (context) => minSupport ? const Boot() : const PlatformNotSupported(),
        "/loadPasswords": (context) => PasswordManager.saveExist
            ? isMobile
                ? const LoginPasswordManagerMobile()
                : const LoginPasswordManagerDesktop()
            : isMobile
                ? const CreatePasswordMobile()
                : const CreatePasswordDesktop(),
        "/passwordMenu": (context) => isMobile ? const PasswordMangerMenuMobile() : const PasswordMangerMenuDesktop(),
        "/AddOrEditPassword": (context) => isMobile ? const AddOrEditPasswordMobile() : const AddOrEditPasswordDesktop(),
        "/viewPassword": (context) => isMobile ? const ViewPasswordMobile() : const ViewPasswordDesktop(),
        "/privacyCenter": (context) => isMobile
            ? PrivacyCenterMobile(
                center: center,
              )
            : PrivacyCenterDesktop(
                center: center,
              ),
        "/settings": (context) => isMobile
            ? SettingsMobile(
                customUrls: center.customUrlObj,
              )
            : SettingsDesktop(
                customUrls: center.customUrlObj,
              ),
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
              fontSize: 20,
            )),
          ),
        ),
        scaffoldBackgroundColor: Colors.black,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.red,
        ),
      ),
      initialRoute: "/",
    ),
  );
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
