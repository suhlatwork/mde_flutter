import 'package:flutter/material.dart';

import 'main_viewer.dart';

void main() => runApp(MaterialApp(
      title: 'mods.de Forum',
      theme: ThemeData(
        primaryColor: Color(0xff111723),
        scaffoldBackgroundColor: Color(0xff111723),
        textTheme: TextTheme(
          title: TextStyle(color: Colors.white),
          subtitle:
              TextStyle(color: Colors.white70, fontWeight: FontWeight.normal),
        ),
      ),
      home: MainViewer(),
    ));
