// TODO: revise once flutter issue 27086 is resolved.
// (https://github.com/flutter/flutter/issues/27086)
// TODO: better closing of server; issue 25100 (related: 27910, 27013)

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

import 'board.dart';
import 'boards.dart';
import 'error_page.dart';
import 'mde_exceptions.dart';
import 'thread.dart';

class HttpServerWrapper {
  static Completer<int> port = Completer<int>();
  static HttpServer _server;

  static start() async {
    MimeTypeResolver mimeTypeResolver = MimeTypeResolver();
    mimeTypeResolver.addExtension(".woff2", "font/woff2");
    mimeTypeResolver.addMagicNumber([0x77, 0x4f, 0x46, 0x32], "font/woff2");

    await stop();

    if (!port.isCompleted) {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv6, 0);
      port.complete(_server.port);
    } else {
      _server = await HttpServer.bind(
          InternetAddress.loopbackIPv6, await port.future);
    }
    debugPrint('start http server ${await port.future}');

    await for (HttpRequest request in _server) {
      if (request.method == 'GET') {
        if (request.uri.path.startsWith('/assets/')) {
          ByteData data = await rootBundle.load(request.uri.path.substring(1));
          ContentType contentType = ContentType.parse(mimeTypeResolver.lookup(
              request.uri.path,
              headerBytes: data.buffer
                  .asUint8List(data.offsetInBytes, data.lengthInBytes)));
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = contentType
            ..add(data.buffer
                .asUint8List(data.offsetInBytes, data.lengthInBytes));
        } else if (request.uri.path.startsWith('/bender/')) {
          final String baseDir = (await getTemporaryDirectory()).path;
          File file = File(baseDir + Uri.decodeComponent(request.uri.path));
          List<int> data = await file.readAsBytes();
          ContentType contentType = ContentType.parse(
              mimeTypeResolver.lookup(request.uri.path, headerBytes: data));
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = contentType
            ..add(data);
        } else if (request.uri.path == '/board') {
          try {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.html
              ..add(utf8.encode(await Board(
                boardId: int.tryParse(request.uri.queryParameters['BID'] ?? ""),
                boardPage:
                    int.tryParse(request.uri.queryParameters['page'] ?? ""),
              ).renderTemplate()));
          } on EmptyBoardPage catch (e) {
            request.response.add(utf8.encode(await ErrorPage(
                    'Keine Seite ${e.boardPage} im Forum "${e.boardName}".')
                .renderTemplate()));
          }
        } else if (request.uri.path == '/boards') {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.html
            ..add(utf8.encode(await Boards().renderTemplate()));
        } else if (request.uri.path == '/thread') {
          try {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.html
              ..add(utf8.encode(await Thread(
                threadId:
                    int.tryParse(request.uri.queryParameters['TID'] ?? ""),
                threadPage:
                    int.tryParse(request.uri.queryParameters['page'] ?? ""),
                postId: int.tryParse(request.uri.queryParameters['PID'] ?? ""),
              ).renderTemplate()));
          } on EmptyThreadPage catch (e) {
            request.response.add(utf8.encode(await ErrorPage(
                    'Keine Seite ${e.threadPage} im Thread "${e.threadName}".')
                .renderTemplate()));
          }
        } else {
          request.response
            ..statusCode = HttpStatus.forbidden
            ..write('No access to: ${request.uri}.');
        }
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Unsupported request: ${request.method}.');
      }
      await request.response.close();
    }
  }

  static stop() async {
    HttpServer server = _server;
    _server = null;

    if (server != null) {
      server.close(force: true);
    }
  }
}
