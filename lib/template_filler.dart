import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:reflected_mustache/mustache.dart';

mixin TemplateFiller {
  final String templateFile = null;

  Completer<Map<String, Object>> content = Completer<Map<String, Object>>();

  Future<String> renderTemplate() async {
    Future<String> template = rootBundle.loadString(templateFile);
    return Template(await template).renderString(await content.future);
  }
}
