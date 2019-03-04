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
