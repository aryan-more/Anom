import 'package:anom/Logic/passwordManager/loading.dart';
import 'package:anom/UI/Desktop/appbar.dart';
import 'package:anom/UI/Desktop/navigationrail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spin;

class LoadingPasswordManagerDesktop extends StatefulWidget {
  const LoadingPasswordManagerDesktop({Key? key}) : super(key: key);

  @override
  _LoadingPasswordManagerDesktopState createState() => _LoadingPasswordManagerDesktopState();
}

class _LoadingPasswordManagerDesktopState extends State<LoadingPasswordManagerDesktop> {
  @override
  void initState() {
    super.initState();
    loadPassword(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bar(),
      body: Row(
        children: [
          NavigationRouteRail(index: 1),
          Expanded(
              child: Center(
            child: spin.SpinKitRing(
              color: Colors.blue,
            ),
          ))
        ],
      ),
    );
  }
}
