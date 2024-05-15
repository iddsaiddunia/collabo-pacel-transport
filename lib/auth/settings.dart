import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color_themes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 37,
                    ),
                    Text(
                      "Nuhu",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text("+25575908765"),
                    MaterialButton(
                      color: color.primaryColor,
                      elevation: 0,
                      onPressed: () {},
                      child: Text(
                        "Edit profile",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
