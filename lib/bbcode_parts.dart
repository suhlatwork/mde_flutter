import 'bbcode_tags.dart';
import 'bbcode_emoji.dart';

class BBCodePart<T extends BBCodeTag> {
  final T tag;
  List<BBCodePart> parts;
  String argument;

  BBCodePart(this.tag, this.parts, [this.argument]);

  BBCodePart deepCopy() {
    BBCodePart copy = BBCodePart(tag, List<BBCodePart>(), argument);
    parts.forEach((element) {
      copy.parts.add(element.deepCopy());
    });
    return copy;
  }

  String toHtml() {
    return tag.toHtml(
        parts.fold('', (prev, element) {
          return prev + element.toHtml();
        }),
        argument);
  }
}

class BBCodePartText extends BBCodePart {
  final String text;
  final BBCodeEmojiParser emojiParser;

  BBCodePartText(this.text, [this.emojiParser]) : super(null, null);

  @override
  BBCodePartText deepCopy() {
    return BBCodePartText(text, emojiParser);
  }

  @override
  String toHtml() {
    return (emojiParser?.toHtml(text) ?? text)
        .replaceAll('\r\n', '<br />')
        .replaceAll('\n', '<br />');
  }
}

class BBCodeDocument extends BBCodePart {
  final Function(BBCodePart) htmlPostProcessor;

  BBCodeDocument(parts, {this.htmlPostProcessor}) : super(null, parts);

  @override
  BBCodeDocument deepCopy() {
    BBCodeDocument copy = BBCodeDocument(List<BBCodePart>(),
        htmlPostProcessor: htmlPostProcessor);
    parts.forEach((element) {
      copy.parts.add(element.deepCopy());
    });
    return copy;
  }

  @override
  String toHtml() {
    if (htmlPostProcessor != null) {
      BBCodeDocument document = this.deepCopy();
      htmlPostProcessor(document);
      return document.parts.fold('', (prev, element) {
        return prev + element.toHtml();
      });
    }

    return parts.fold('', (prev, element) {
      return prev + element.toHtml();
    });
  }
}
