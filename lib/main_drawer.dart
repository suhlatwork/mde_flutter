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

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'bookmarks.dart';
import 'http_server.dart';
import 'mde_account.dart';

class MainDrawer extends StatefulWidget {
  final Completer<WebViewController> controllerCompleter;

  MainDrawer({
    Key key,
    @required this.controllerCompleter,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  Future<bool> _canNavigateBack;
  Future<bool> _canNavigateForward;
  Future<String> _userName;
  Future<List<BookmarkItem>> _bookmarkList;
  Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();

    _canNavigateBack = widget.controllerCompleter.future
        .then((controller) => controller.canGoBack());
    _canNavigateForward = widget.controllerCompleter.future
        .then((controller) => controller.canGoForward());
    _userName = MDEAccount.userName();
    _bookmarkList = Bookmarks().bookmarkListCompleter.future;
    _packageInfo = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: _bookmarkList,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> children = [
            ListTile(
              title: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () async {
                      Uri uri = Uri.http('', '').replace(
                        host: InternetAddress.loopbackIPv6.host,
                        path: '/boards',
                        port: await HttpServerWrapper.port.future,
                      );
                      (await widget.controllerCompleter.future)
                          .loadUrl(uri.toString());
                      Navigator.pop(context);
                    },
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async {
                      (await widget.controllerCompleter.future).reload();
                      Navigator.pop(context);
                    },
                  ),
                  FutureBuilder(
                    future: _canNavigateBack,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data) {
                        return IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () async {
                            (await widget.controllerCompleter.future).goBack();
                            Navigator.pop(context);
                          },
                        );
                      }
                      return IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: null,
                      );
                    },
                  ),
                  FutureBuilder(
                    future: _canNavigateForward,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data) {
                        return IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () async {
                            (await widget.controllerCompleter.future)
                                .goForward();
                            Navigator.pop(context);
                          },
                        );
                      }
                      return IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: null,
                      );
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            FutureBuilder(
              future: _userName,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    return ListTile(
                      leading: Icon(Icons.account_circle),
                      onTap: () async {
                        bool success = await MDEAccount.logout();

                        Navigator.pop(context);

                        Scaffold.of(context).removeCurrentSnackBar();
                        if (success) {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Benutzer "${snapshot.data}" erfolgreich abgemeldet.',
                              ),
                            ),
                          );
                        } else {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Lokale Sitzungsdaten für Benutzer "${snapshot.data}" gelöscht, Sitzungsdaten auf den mods.de Servern konnten nicht gelöscht werden.',
                              ),
                            ),
                          );
                        }
                      },
                      title: Text('${snapshot.data} abmelden'),
                    );
                  }

                  return ListTile(
                    leading: Icon(Icons.account_circle),
                    onTap: () async {
                      if (await MDEAccount.loginDialog(context)) {
                        await (await widget.controllerCompleter.future)
                            .reload();
                      }
                      Navigator.pop(context);
                    },
                    title: Text('Benutzer anmelden'),
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Divider(),
          ];

          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.isNotEmpty) {
              List<Widget> entries = snapshot.data.where((BookmarkItem item) {
                return ((item.unreadPosts != 0) || (item.threadClosed == true));
              }).map<Widget>((BookmarkItem item) {
                return ListTile(
                    onLongPress: () async {
                      final bool remove = await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Lesezeichen entfernen'),
                            content: Text(
                                'Soll das Lesezeichen für den Thread "${item.threadTitle}" wirklich entfernt werden?'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Behalten'),
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                              ),
                              FlatButton(
                                child: Text('Entfernen'),
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (remove ?? false) {
                        await MDEAccount.removeBookmark(
                          bookmarkId: item.bookmarkId,
                          removeBookmarkToken: item.removeBookmarkToken,
                        );
                        // update bookmark list
                        setState(() {});
                      }
                    },
                    onTap: () async {
                      final Uri uri = Uri.http('', '').replace(
                        host: InternetAddress.loopbackIPv6.host,
                        path: '/thread',
                        port: await HttpServerWrapper.port.future,
                        queryParameters: {
                          'TID': item.threadId.toString(),
                          'PID': item.postId.toString(),
                        },
                      );
                      (await widget.controllerCompleter.future)
                          .loadUrl(uri.toString());
                      Navigator.pop(context);
                    },
                    title: Text(
                      item.threadTitle,
                      overflow: TextOverflow.ellipsis,
                      style: item.threadClosed
                          ? TextStyle(decoration: TextDecoration.lineThrough)
                          : TextStyle(),
                    ),
                    trailing: ((item.unreadPosts > 0)
                        ? Text(
                            item.unreadPosts.toString(),
                          )
                        : null));
              }).toList();

              if (entries.length > 0) {
                children.addAll(entries);
                children.add(Divider());
              }
            }
          } else {
            children.addAll(
              <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                ),
                Divider(),
              ],
            );
          }

          children.add(
            FutureBuilder(
              future: _packageInfo,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AboutListTile(
                    applicationName: snapshot.data.appName,
                    applicationVersion: snapshot.data.version,
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          );

          return ListView(
            children: children,
          );
        },
      ),
    );
  }
}
