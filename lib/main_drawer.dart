import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'bookmarks.dart';
import 'http_server.dart';

class MainDrawer extends StatefulWidget {
  final Completer<WebViewController> controllerCompleter;

  const MainDrawer({
    Key key,
    @required this.controllerCompleter,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: Bookmarks().bookmarkListCompleter.future,
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
                    future: widget.controllerCompleter.future
                        .then((controller) => controller.canGoBack()),
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
                    future: widget.controllerCompleter.future
                        .then((controller) => controller.canGoForward()),
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
          ];

          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.isNotEmpty) {
              children.add(Divider());
              children.addAll(
                snapshot.data.where((BookmarkItem item) {
                  return item.unreadPosts != 0;
                }).map<Widget>((BookmarkItem item) {
                  return ListTile(
                      onLongPress: () {},
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
                      trailing: Text(
                        item.unreadPosts.toString(),
                      ));
                }),
              );
            }
          } else {
            children.addAll(
              <Widget>[
                Divider(),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            );
          }

          return ListView(
            children: children,
          );
        },
      ),
    );
  }
}
