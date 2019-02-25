import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

MDEBenderCache mdeBenderCache = MDEBenderCache._();

class MDEBenderCache {
  MDEBenderCache._();

  Future<String> html(final String avatar) async {
    final String cleanUri = url.normalize(avatar);
    final String localUri = url.normalize(url.joinAll(['/bender', cleanUri]));

    if (await _check(cleanUri)) {
      return 'style="background-image:url($localUri)"';
    }

    return '';
  }

  Future<bool> _check(final String cleanUri) async {
    final String baseDir = (await getTemporaryDirectory()).path;
    final String fullPath = join(baseDir, 'bender', joinAll(url.split(cleanUri)));

    File file = File(fullPath);
    if (await file.exists()) {
      return true;
    }

    Directory dir = Directory(dirname(fullPath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return _load(cleanUri, fullPath);
  }

  Future<bool> _load(final String cleanUri, final String fullPath) async {
    ConnectivityResult connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.wifi) {
      return false;
    }

    debugPrint(Uri.http('forum.mods.de', url.join('bb', cleanUri)).toString());
    http.Response response = await http.get(Uri.http('forum.mods.de', url.join('bb', cleanUri)));

    await File(fullPath).writeAsBytes(response.bodyBytes);

    return true;
  }
}
