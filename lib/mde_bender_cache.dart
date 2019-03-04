import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

MDEBenderCache mdeBenderCache = MDEBenderCache._();

class MDEBenderCache {
  MDEBenderCache._();

  Future<String> html(final String avatar) async {
    final String cleanUri = url.normalize(avatar);

    if (await _check(cleanUri)) {
      final String localUri = Uri(
        path: url.normalize(url.joinAll(['/bender', cleanUri])),
      ).path;
      return 'style="background-image:url($localUri)"';
    }

    return '';
  }

  Future<bool> _check(final String cleanUri) async {
    final String baseDir = (await getTemporaryDirectory()).path;
    final String fullPath =
        join(baseDir, 'bender', joinAll(url.split(cleanUri)));

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

    debugPrint(Uri.http(
      'forum.mods.de',
      url.join('bb', cleanUri),
    ).toString());

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.http(
      'forum.mods.de',
      url.join('bb', cleanUri),
    ));
    HttpClientResponse response = await request.close();

    await File(fullPath).writeAsBytes(
      await response.reduce(
        (List<int> first, List<int> second) {
          return first + second;
        },
      ),
    );

    return true;
  }
}
