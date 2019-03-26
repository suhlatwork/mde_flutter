// mde_flutter - A cross platform viewer for the mods.de forum.
// Copyright (C) 2019  Sebastian Uhl
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
