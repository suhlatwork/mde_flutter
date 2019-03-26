// mde_flutter - A cross platform viewer for the mods.de forum.
// Copyright (C) 2019  Sebastian Uhl
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

class PasswordDialog extends StatefulWidget {
  PasswordDialog({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  String username;
  String password;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        Center(
          child: Text('Benutzername'),
        ),
        Padding(
          child: TextField(
            onChanged: (final String content) {
              username = content;
            },
          ),
          padding: EdgeInsets.all(24),
        ),
        Center(
          child: Text('Passwort'),
        ),
        Padding(
          child: TextField(
            obscureText: true,
            onChanged: (final String content) {
              password = content;
            },
          ),
          padding: EdgeInsets.all(24),
        ),
        FlatButton.icon(
          icon: Icon(Icons.account_circle),
          label: Text('Login'),
          onPressed: () {
            Navigator.pop(
              context,
              <String>[
                username,
                password,
              ],
            );
          },
        ),
        FlatButton.icon(
          icon: Icon(Icons.cancel),
          label: Text('Weiter ohne Login'),
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
      ],
      title: Text('Login'),
    );
  }
}
