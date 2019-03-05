import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'http_server.dart';
import 'main_drawer.dart';
import 'mde_account.dart';
import 'mde_exceptions.dart';

class MainViewer extends StatefulWidget {
  @override
  _MainViewerState createState() => _MainViewerState();
}

class _MainViewerState extends State<MainViewer> with WidgetsBindingObserver {
  Completer<WebViewController> _controllerCompleter;

  String _appBarTitle;

  _MainViewerState()
      : _controllerCompleter = Completer<WebViewController>(),
        _appBarTitle = '' {
    HttpServerWrapper.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
      ),
      body: Center(
        child: WillPopScope(
          child: FutureBuilder(
            future: HttpServerWrapper.port.future,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return WebView(
                  // TODO: remove after https://github.com/flutter/flutter/issues/24585
                  gestureRecognizers:
                      Set<Factory<OneSequenceGestureRecognizer>>.of([
                    Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                    Factory<LongPressGestureRecognizer>(
                        () => LongPressGestureRecognizer()),
                  ]),
                  initialUrl: Uri.http('', '')
                      .replace(
                        host: InternetAddress.loopbackIPv6.host,
                        path: '/boards',
                        port: snapshot.data,
                      )
                      .toString(),
                  javascriptChannels: Set<JavascriptChannel>.of([
                    JavascriptChannel(
                      name: 'appBarTitleSetter',
                      onMessageReceived: (final JavascriptMessage message) {
                        _handleAppBarTitleSetter(message.message);
                      },
                    ),
                    JavascriptChannel(
                      name: 'checkUserId',
                      onMessageReceived: (final JavascriptMessage message) {
                        _handleCheckUserId(context, message.message);
                      },
                    ),
                    JavascriptChannel(
                      name: 'errorDisplay',
                      onMessageReceived: (final JavascriptMessage message) {
                        _handleErrorDisplay(context, message.message);
                      },
                    ),
                    JavascriptChannel(
                      name: 'setBookmark',
                      onMessageReceived: (final JavascriptMessage message) {
                        _handleSetBookmark(context, message.message);
                      },
                    ),
                    JavascriptChannel(
                      name: 'urlOpener',
                      onMessageReceived: (final JavascriptMessage message) {
                        _handleUrlOpener(context, message.message);
                      },
                    ),
                  ]),
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController controller) {
                    _controllerCompleter.complete(controller);
                  },
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          onWillPop: () async {
            // peek at the current route and see whether a pop would be handled
            // internally, i.e., whether a drawer would be closed, ...
            bool handlePopInternally = false;
            Navigator.of(context).popUntil(
              (Route route) {
                if (route.willHandlePopInternally) {
                  handlePopInternally = true;
                }
                return true;
              },
            );
            if (handlePopInternally) {
              return true;
            }

            // else go back in web view
            if (await (await _controllerCompleter.future).canGoBack()) {
              (await _controllerCompleter.future).goBack();
              return false;
            }

            return true;
          },
        ),
      ),
      drawer: new MainDrawer(controllerCompleter: _controllerCompleter),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      HttpServerWrapper.start();
    } else if (state == AppLifecycleState.paused) {
      HttpServerWrapper.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  _handleAppBarTitleSetter(final String newAppBarTitle) {
    setState(() {
      _appBarTitle = newAppBarTitle;
    });
  }

  _handleCheckUserId(BuildContext context, final String message) async {
    final int currentUserId = int.parse(message);

    final bool preferencesShowLoginDialog = await MDEAccount.showLoginDialog();
    final int preferencesUserId = await MDEAccount.userId();

    bool showLoginDialog =
        ((currentUserId == 0) && preferencesShowLoginDialog) ||
            (preferencesUserId == null && preferencesShowLoginDialog) ||
            (preferencesUserId != null && preferencesUserId != currentUserId);

    if (showLoginDialog) {
      if (await MDEAccount.loginDialog(context)) {
        await (await _controllerCompleter.future).reload();
      }
    }
  }

  _handleErrorDisplay(BuildContext context, final String message) async {
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
    if (await (await _controllerCompleter.future).canGoBack()) {
      (await _controllerCompleter.future).goBack();
    }
  }

  _handleSetBookmark(BuildContext context, final String address) async {
    final Map<String, dynamic> arguments = jsonDecode(address);

    try {
      await MDEAccount.addBookmark(
        postId: arguments['postId'],
        setBookmarkToken: arguments['setBookmarkToken'],
      );

      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lesezeichen für Thread "${arguments['threadTitle']}" gesetzt.',
          ),
        ),
      );
    } on TooManyBookmarks {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lesezeichen für Thread "${arguments['threadTitle']}" konnte nicht gesetzt werden: zu viele Lesezeichen.',
          ),
        ),
      );
    } on UnspecificBookmarkError {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lesezeichen für Thread "${arguments['threadTitle']}" konnte nicht gesetzt werden.',
          ),
        ),
      );
    }
  }

  _handleUrlOpener(BuildContext context, final String address) async {
    final Uri uri = Uri.parse(address);

    // intercept calls to the forum
    if (uri.isScheme('http') && uri.host == 'forum.mods.de') {
      Uri localUri;

      if (uri.path == '/bb/board.php') {
        if (uri.queryParameters.length == 2 &&
            uri.queryParameters.containsKey('BID') &&
            uri.queryParameters.containsKey('page')) {
          localUri = Uri.http('', '').replace(
            host: InternetAddress.loopbackIPv6.host,
            path: '/board',
            port: await HttpServerWrapper.port.future,
            queryParameters: uri.queryParameters,
          );
        } else if (uri.queryParameters.length == 1 &&
            uri.queryParameters.containsKey('BID')) {
          localUri = Uri.http('', '').replace(
            host: InternetAddress.loopbackIPv6.host,
            path: '/board',
            port: await HttpServerWrapper.port.future,
            queryParameters: uri.queryParameters,
          );
        }
      } else if (uri.path == '/bb/thread.php') {
        if (uri.queryParameters.length == 2 &&
            uri.queryParameters.containsKey('TID') &&
            uri.queryParameters.containsKey('PID')) {
          localUri = Uri.http('', '').replace(
            host: InternetAddress.loopbackIPv6.host,
            path: '/thread',
            port: await HttpServerWrapper.port.future,
            queryParameters: uri.queryParameters,
          );
        } else if (uri.queryParameters.length == 2 &&
            uri.queryParameters.containsKey('TID') &&
            uri.queryParameters.containsKey('page')) {
          localUri = Uri.http('', '').replace(
            host: InternetAddress.loopbackIPv6.host,
            path: '/thread',
            port: await HttpServerWrapper.port.future,
            queryParameters: uri.queryParameters,
          );
        } else if (uri.queryParameters.length == 1 &&
            uri.queryParameters.containsKey('TID')) {
          localUri = Uri.http('', '').replace(
            host: InternetAddress.loopbackIPv6.host,
            path: '/thread',
            port: await HttpServerWrapper.port.future,
            queryParameters: uri.queryParameters,
          );
        }
      }

      if (localUri != null) {
        (await _controllerCompleter.future).loadUrl(localUri.toString());
        return;
      } else {
        throw ArgumentError.value(uri.toString(), 'address', 'missing handler');
      }
    }

    if (uri.isScheme('http') || uri.isScheme('https')) {
      launch(uri.toString());
      return;
    }

    throw ArgumentError.value(uri.toString(), 'address', 'missing handler');
  }
}
