import 'template_filler.dart';

class ErrorPage with TemplateFiller {
  final String templateFile = 'assets/error.html';

  ErrorPage(final String errorMessage) {
    content.complete({
      'errorMessage': errorMessage,
    });
  }
}
