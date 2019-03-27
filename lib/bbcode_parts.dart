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

import 'bbcode_tags.dart';
import 'bbcode_emoji.dart';

class BBCodePart<T extends BBCodeTag> {
  final T tag;
  final String bbCode;
  List<BBCodePart> parts;
  String argument;

  BBCodePart(this.tag, this.bbCode, this.parts, [this.argument]);

  BBCodePart deepCopy() {
    BBCodePart copy = BBCodePart(tag, bbCode, List<BBCodePart>(), argument);
    parts.forEach(
      (element) {
        copy.parts.add(element.deepCopy());
      },
    );
    return copy;
  }

  String toHtml() {
    return tag.toHtml(
        parts.fold(
          '',
          (prev, element) {
            return prev + element.toHtml();
          },
        ),
        argument);
  }
}

class BBCodePartText extends BBCodePart {
  final BBCodeEmojiParser emojiParser;

  BBCodePartText(final String text, [this.emojiParser])
      : super(null, text, null);

  @override
  BBCodePartText deepCopy() {
    return BBCodePartText(bbCode, emojiParser);
  }

  @override
  String toHtml() {
    return (emojiParser?.toHtml(bbCode) ?? bbCode)
        .replaceAll('\r\n', '<br />')
        .replaceAll('\n', '<br />');
  }
}

class BBCodeDocument extends BBCodePart {
  final Function(BBCodePart) htmlPostProcessor;

  BBCodeDocument(bbCode, parts, {this.htmlPostProcessor})
      : super(null, bbCode, parts);

  @override
  BBCodeDocument deepCopy() {
    BBCodeDocument copy = BBCodeDocument(bbCode, List<BBCodePart>(),
        htmlPostProcessor: htmlPostProcessor);
    parts.forEach(
      (element) {
        copy.parts.add(element.deepCopy());
      },
    );
    return copy;
  }

  @override
  String toHtml() {
    if (htmlPostProcessor != null) {
      BBCodeDocument document = this.deepCopy();
      htmlPostProcessor(document);
      return document.parts.fold(
        '',
        (prev, element) {
          return prev + element.toHtml();
        },
      );
    }

    return parts.fold(
      '',
      (prev, element) {
        return prev + element.toHtml();
      },
    );
  }
}
