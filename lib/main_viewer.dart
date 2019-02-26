import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'http_server.dart';

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
              if (snapshot.hasData) {
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
                      name: 'errorDisplay',
                      onMessageReceived: (final JavascriptMessage message) {
                        _handleErrorDisplay(context, message.message);
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
            if (await (await _controllerCompleter.future).canGoBack()) {
              (await _controllerCompleter.future).goBack();
              return false;
            }
            return true;
          },
        ),
      ),
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

  _handleErrorDisplay(BuildContext context, final String message) async {
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (await (await _controllerCompleter.future).canGoBack()) {
      (await _controllerCompleter.future).goBack();
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
