import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

final closeButtonColors = WindowButtonColors(mouseOver: const Color(0xFFD32F2F), mouseDown: const Color(0xFFB71C1C), iconNormal: Colors.white, iconMouseOver: Colors.white);
final buttonColors = WindowButtonColors(iconNormal: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

PreferredSize bar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(35),
    child: Container(
      color: const Color(0xA0000000),
      child: WindowTitleBarBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(child: MoveWindow()),
            const WindowButtons(),
          ],
        ),
      ),
    ),
  );
}

class GetGeometry {
  late double height;
  late double width;

  void getGeometry(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
  }
}
