import 'package:flutter/material.dart';

final routes = ["/privacyCenter", "/loadPasswords"];

class NavigationRouteRail extends StatelessWidget {
  final int index;
  const NavigationRouteRail({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        NavigationRail(
          destinations: [
            for (var item in [
              [0, Icons.shield, "Privacy Center"],
              [1, Icons.vpn_key, "Password Manager"]
            ])
              NavigationRailDestination(icon: Icon(item[1] as IconData), label: Text(item[2] as String))
          ],
          selectedIndex: index,
          onDestinationSelected: (x) {
            if (index != x) {
              Navigator.of(context).pushReplacementNamed(routes[x]);
            }
          },
          backgroundColor: Colors.black,
        ),
        VerticalDivider(
          indent: 3,
          endIndent: 3,
          thickness: 2,
          color: Colors.grey[700],
        )
      ],
    );
  }
}
