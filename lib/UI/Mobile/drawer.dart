import 'package:flutter/material.dart';

class DrawerRoute extends StatelessWidget {
  DrawerRoute({Key? key, required this.index, this.func}) : super(key: key);
  Function? func;
  // double height = 0;
  final int index;
  final routes = [
    [0, "Privacy Center", "/privacyCenter", Icons.shield],
    [1, "Password Manager", "/loadPasswords", Icons.vpn_key],
    [2, "Settings", "/settings", Icons.settings]
  ];

  @override
  Widget build(BuildContext context) {
    // height =;
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height * 0.25,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [Text("Anom")],
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, pos) => ListTile(
                      trailing: Icon(routes[pos][3] as IconData),
                      title: Text("${routes[pos][1]}"),
                      onTap: () {
                        if (pos == index) {
                          Navigator.of(context).pop();
                        } else {
                          if (func != null) {
                            func!();
                          } else {
                            print("object");
                          }
                          Navigator.of(context).pushNamed(routes[pos][2] as String);
                        }
                      },
                    )),
          ),
        ],
      ),
    );
  }
}
