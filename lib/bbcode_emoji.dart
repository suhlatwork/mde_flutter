class BBCodeEmoji {
  final String code;
  final String html;

  BBCodeEmoji(this.code, {this.html});
}

class BBCodeEmojiParser {
  final List<BBCodeEmoji> _emojis;
  final List<String> _ignoreTags;

  BBCodeEmojiParser(this._emojis, [this._ignoreTags = const []]);

  bool parseInTag(final String tag) {
    return _ignoreTags.indexOf(tag) == -1;
  }

  bool parseInTags(final List<String> tags) {
    return tags.fold(
      true,
      (prev, tag) {
        return prev & (_ignoreTags.indexOf(tag) == -1);
      },
    );
  }

  String toHtml(String text) {
    for (final BBCodeEmoji emoji in _emojis) {
      text = text.replaceAll(emoji.code, emoji.html);
    }

    return text;
  }
}
