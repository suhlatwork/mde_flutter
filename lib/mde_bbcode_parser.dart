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

import 'dart:convert';

import 'bbcode_parser.dart';
export 'bbcode_parser.dart';

import 'mde_smileys.dart';

class _QuoteTag extends BBCodeTag {
  _QuoteTag() : super('quote');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    if (argument != null) {
      final int split1 = (argument as String).indexOf(',');
      final int split2 = (argument as String).indexOf(',', split1 + 1);

      final int threadId = int.parse((argument as String).substring(0, split1));
      final int postId =
          int.parse((argument as String).substring(split1 + 1, split2));

      String author = (argument as String).substring(split2 + 1);
      if (author.startsWith('"') && author.endsWith('"')) {
        author = author.substring(1, author.length - 1);
      }
      author = HtmlEscape().convert(author);

      return '<div class="quote">'
          '<a href="http://forum.mods.de/bb/thread.php?TID=$threadId&PID=$postId" class="author">'
          '<i class="material-icons">&#xE244;</i>'
          '$author</a>'
          '<div class="content">$innerHtml</div>'
          '</div>';
    }

    return '<div class="quote"><div class="content">$innerHtml</div></div>';
  }

  @override
  String toBBCode(final dynamic argument, final String innerBBCode) {
    String reference = '';
    if (argument != null) {
      reference = '=$argument';
    }

    return '[$bbTag$reference]$innerBBCode[/$bbTag]';
  }
}

class _MonospaceTag extends BBCodeTag {
  _MonospaceTag() : super('m');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<pre class="inline">$innerHtml</pre>';
  }
}

class _StrikeTag extends BBCodeTag {
  _StrikeTag() : super('s');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<span class="strike">$innerHtml</span>';
  }
}

class _ModTag extends BBCodeTag {
  _ModTag() : super('mod');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<span class="mod">$innerHtml</span>';
  }
}

class _SpoilerTag extends BBCodeTag {
  _SpoilerTag() : super('spoiler');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<div class="media spoiler">'
        '<i class="material-icons">&#xE8F5;</i>'
        '<button class="viewer mdl-button mdl-js-button">Spoiler zeigen</button>'
        '<div class="spoiler-content">$innerHtml</div>'
        '</div>';
  }
}

class _TriggerTag extends BBCodeTag {
  _TriggerTag() : super('trigger');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<span class="trigger">$innerHtml</span>';
  }
}

class _CodeTag extends BBCodeTag {
  _CodeTag() : super('code', container: false);

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<div class="code">$innerHtml</div>';
  }
}

class _TexTag extends BBCodeTag {
  _TexTag() : super('tex', container: false);

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    Uri uri = Uri.https(
      'chart.googleapis.com',
      'chart',
      {
        'chco': 'ffffff',
        'chf': 'bg,s,394E63',
        'cht': 'tx',
        'chl': innerBBCode,
      },
    );
    return '<img src="$uri" class="tex" />';
  }
}

class _ImageTag extends BBCodeTag {
  _ImageTag() : super('img', container: false);

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    String typeClass = 'img';
    String icon = '&#xE410;';

    Uri url = Uri.tryParse(innerBBCode);
    if (url == null) {
      final String text = HtmlEscape().convert(innerBBCode);
      return '<strong>Ungültige Bildaddresse:<strong> &quot;$text&quot;';
    }

    if (url.path.endsWith('gif')) {
      typeClass = 'gif';
      icon = '&#xE54D;';
    }

    return '<div class="media $typeClass" data-src="${url.toString()}">'
        '<i class="material-icons">$icon</i>'
        '<button class="inline mdl-button mdl-js-button">Inline</button>'
        '<button class="viewer mdl-button mdl-js-button">Viewer</button>'
        '</div>';
  }
}

class _VideoTag extends BBCodeTag {
  _VideoTag() : super('video');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    Uri uri = Uri.tryParse(innerBBCode);
    if (uri == null) {
      final String text = HtmlEscape().convert(innerBBCode);
      return '<strong>Ungültiger Link:<strong> &quot;$text&quot;';
    }

    if (uri.host == "www.youtube.com" || uri.host == "youtu.be") {
      String id;
      if (uri.host == "www.youtube.com") {
        if (uri.path == '/watch' && uri.queryParameters.containsKey('v')) {
          id = uri.queryParameters['v'];
        } else if (uri.path.startsWith('/embed/')) {
          id = uri.pathSegments[1];
        }
      } else if (uri.host == "youtu.be") {
        id = uri.pathSegments[0];
      }

      return '<div class="media video yt" data-id="$id">'
          '<i class="material-icons">&#xE02C;</i>'
          '<button class="inline mdl-button mdl-js-button">Inline</button>'
          '<button class="link mdl-button mdl-js-button">Youtube</button>'
          '</div>';
    }

    return '<div class="media video" data-src="${uri.toString()}">'
        '<i class="material-icons">&#xE54D;</i>'
        '<button class="inline mdl-button mdl-js-button">Inline</button>'
        '<button class="viewer mdl-button mdl-js-button">Viewer</button>'
        '</div>';
  }
}

class _UrlTag extends BBCodeTag {
  _UrlTag() : super('url');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    if (argument == null) {
      final String url = innerBBCode;
      final Uri uri = Uri.tryParse(url);

      final String text = HtmlEscape().convert(url);

      if (uri == null) {
        return '<strong>Ungültiger Link:<strong> &quot;$text&quot;';
      }

      return '<a href="${uri.toString()}">$text</a>';
    }

    String url = argument as String;
    if (url.startsWith('"') && url.endsWith('"')) {
      url = url.substring(1, url.length - 1);
    }
    final Uri uri = Uri.tryParse(url);

    if (uri == null) {
      final String text = HtmlEscape().convert(url);
      return '<strong>Ungültiger Link:<strong> &quot;$text&quot; mit Text &quot;$innerHtml&quot;';
    }

    return '<a href="$url">$innerHtml</a>';
  }

  @override
  String toBBCode(final dynamic argument, final String innerBBCode) {
    String url = '';
    if (argument != null) {
      url = '=$argument';
    }

    return '[$bbTag$url]$innerBBCode[/$bbTag]';
  }
}

class _UrlImageTag extends BBCodeTag {
  _UrlImageTag() : super('', container: false);

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    final List<String> arguments = argument as List<String>;
    if (arguments[0].startsWith('"') && arguments[0].endsWith('"')) {
      arguments[0] = arguments[0].substring(1, arguments[0].length - 1);
    }

    Uri urlLink = Uri.tryParse(arguments[0]);
    Uri urlImage = Uri.tryParse(arguments[1]);

    if (urlLink == null) {
      final String text = HtmlEscape().convert(arguments[0]);
      return '<strong>Ungültiger Link:<strong> &quot;$text&quot;';
    }

    if (urlImage == null) {
      final String text = HtmlEscape().convert(arguments[1]);
      return '<strong>Ungültige Bildaddresse:<strong> &quot;$text&quot;';
    }

    String typeClass = 'img-link';
    String icon = '&#xE410;';

    if (urlImage.path.endsWith('gif')) {
      typeClass = 'gif-link';
      icon = '&#xE54D;';
    }

    return '<div class="media $typeClass" data-src="${urlImage.toString()}" data-href="${urlLink.toString()}">'
        '<i class="material-icons">$icon</i>'
        '<button class="link mdl-button mdl-js-button">Link</button>'
        '<button class="inline mdl-button mdl-js-button">Inline</button>'
        '<button class="viewer mdl-button mdl-js-button">Viewer</button>'
        '</div>';
  }
}

int _processUrlImageFindSplit(final BBCodePart part) {
  if (part.parts != null) {
    for (int i = 0; i < part.parts.length; i++) {
      if (part.parts[i].tag == null) {
        continue;
      }
      if (part.parts[i].tag.bbTag == _ImageTag().bbTag) {
        return i;
      }
      if (_processUrlImageFindSplit(part.parts[i]) != null) {
        return i;
      }
    }
  }

  return null;
}

BBCodePart _processUrlImageSplitFirst(final BBCodePart part) {
  final int split = _processUrlImageFindSplit(part);
  if (split == null) {
    return null;
  }

  BBCodePart splitPart = part.deepCopy();
  splitPart.parts.removeRange(split, splitPart.parts.length);

  BBCodePart last = _processUrlImageSplitFirst(part.parts[split]);
  if (last != null) {
    if (last.parts == null || last.parts.length > 0) {
      splitPart.parts.add(last);
    }
  }

  return splitPart;
}

BBCodePart _processUrlImageSplitSecond(final BBCodePart part) {
  final int split = _processUrlImageFindSplit(part);
  if (split == null) {
    return part;
  }

  return _processUrlImageSplitSecond(part.parts[split]);
}

BBCodePart _processUrlImageSplitThird(final BBCodePart part) {
  final int split = _processUrlImageFindSplit(part);
  if (split == null) {
    return null;
  }

  BBCodePart splitPart = part.deepCopy();
  splitPart.parts.removeRange(0, split + 1);

  BBCodePart first = _processUrlImageSplitThird(part.parts[split]);
  if (first != null) {
    if (first.parts == null || first.parts.length > 0) {
      splitPart.parts.insert(0, first);
    }
  }

  return splitPart;
}

_processMDEBBCode(BBCodePart part) {
  if (part.tag != null) {
    // remove the bold take from within quotes
    if (part.tag.bbTag == _QuoteTag().bbTag &&
        part.parts.length == 1 &&
        part.parts[0].tag != null &&
        part.parts[0].tag.bbTag == BBCodeBoldTag().bbTag) {
      part.parts = part.parts[0].parts;
    }
  }

  if (part.parts != null) {
    // images inside urls need to be treated specially
    for (int i = 0; i < part.parts.length; i++) {
      if (part.parts[i].tag == null) {
        continue;
      }
      if (part.parts[i].tag.bbTag != _UrlTag().bbTag) {
        continue;
      }

      BBCodePart currentPart = part.parts[i].deepCopy();

      // is there a img inside a url
      final int split = _processUrlImageFindSplit(currentPart);
      // if there is, create two copys of the current part
      if (split != null) {
        BBCodePart firstPart = _processUrlImageSplitFirst(currentPart);
        if (firstPart.parts.length > 0) {
          part.parts.insert(i, firstPart);
          i += 1;
        }

        final BBCodePart secondPart = _processUrlImageSplitSecond(currentPart);
        part.parts[i] = BBCodePart(
          _UrlImageTag(),
          currentPart.bbCode,
          secondPart.parts,
          <String>[currentPart.argument, secondPart.bbCode],
        );

        BBCodePart thirdPart = _processUrlImageSplitThird(currentPart);
        if (thirdPart.parts.length > 0) {
          part.parts.insert(i + 1, thirdPart);
          i += 1;
        }
      }
    }
  }

  // recursively process all elements
  if (part.parts != null) {
    part.parts.forEach(_processMDEBBCode);
  }
}

class MDEBBCodeParser extends BBCodeParser {
  MDEBBCodeParser()
      : super(
          <BBCodeTag>[
            BBCodeBoldTag(),
            BBCodeUnderlineTag(),
            BBCodeItalicTag(),
            BBCodeListTag(),
            BBCodeListItemTag(),
            BBCodeTableTag(),
            BBCodeTableRowTag(),
            BBCodeTableColumnTag(),
            _QuoteTag(),
            _MonospaceTag(),
            _StrikeTag(),
            _ModTag(),
            _SpoilerTag(),
            _TriggerTag(),
            _CodeTag(),
            _TexTag(),
            _ImageTag(),
            _VideoTag(),
            _UrlTag(),
          ],
          emojiParser: BBCodeEmojiParser(
            mdeSmileys,
            <BBCodeTag>[
              _CodeTag(),
              _TexTag(),
              _ImageTag(),
              _VideoTag(),
              _UrlTag(),
            ].map(
              (element) {
                return element.bbTag;
              },
            ).toList(),
          ),
          htmlPostProcessor: _processMDEBBCode,
        );
}

BBCodePart _transformImageToUrl(BBCodePart part) {
  if (part.tag == null) {
    if (part.parts != null) {
      throw Error();
    }
    return part.deepCopy();
  }

  BBCodePart copy;
  if (part.tag.bbTag == 'img') {
    copy =
        BBCodePart(_UrlTag(), part.bbCode, List<BBCodePart>(), part.argument);
  } else {
    copy = BBCodePart(part.tag, part.bbCode, List<BBCodePart>(), part.argument);
  }

  part.parts.forEach(
    (element) {
      copy.parts.add(_transformImageToUrl(element));
    },
  );

  return copy;
}

BBCodeDocument transformImageToUrl(BBCodeDocument document) {
  BBCodeDocument copy = BBCodeDocument(document.bbCode, List<BBCodePart>(),
      htmlPostProcessor: document.htmlPostProcessor);

  document.parts.forEach(
    (element) {
      copy.parts.add(_transformImageToUrl(element));
    },
  );

  return copy;
}
