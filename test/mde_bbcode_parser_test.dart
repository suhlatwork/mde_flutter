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

import 'package:test/test.dart';

import 'package:mde_flutter/mde_bbcode_parser.dart';

void main() {
  MDEBBCodeParser mdebbCodeParser = MDEBBCodeParser();

  test(
    'no container tag',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse('[code]text[/code]');
      expect(result.toHtml(), '<div class="code">text</div>');
    },
  );

  test(
    'no container tag missing closing',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse('[code]text');
      expect(result.toHtml(), '<div class="code">text</div>');
    },
  );

  test(
    'no container tag in bold',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[b]bold [code]text[/b]');
      expect(result.toHtml(),
          '<strong>bold <div class="code">text</div></strong>');
    },
  );

  test(
    'bold in no container tag',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[code]text in [b]bold[/b][/code]');
      expect(
          result.toHtml(), '<div class="code">text in [b]bold[&#47;b]</div>');
    },
  );

  test(
    'broken bold in no container tag',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[code]text in [b]bold[/code]');
      expect(result.toHtml(), '<div class="code">text in [b]bold</div>');
    },
  );

  test(
    'bold tag inside quote',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[quote][b]text[/b][/quote]');
      expect(result.toHtml(),
          '<div class="quote"><div class="content">text</div></div>');
    },
  );

  test(
    'bold tag inside quote with bold text',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[quote][b]text in [b]bold[/b][/b][/quote]');
      expect(result.toHtml(),
          '<div class="quote"><div class="content">text in <strong>bold</strong></div></div>');
    },
  );

  test(
    'quote with reference',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[quote=1,1,"[CSF]Omega"][b]text[/b][/quote]');
      expect(result.toHtml(),
          '<div class="quote"><a href="http://forum.mods.de/bb/thread.php?TID=1&PID=1" class="author"><i class="material-icons">&#xE244;</i>[CSF]Omega</a><div class="content">text</div></div>');
    },
  );

  test(
    'img',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[img]https://flutter.dev/images/favicon.png[/img]');
      expect(result.toHtml(),
          '<div class="media img" data-src="https://flutter.dev/images/favicon.png"><i class="material-icons">&#xE410;</i><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div>');
    },
  );

  test(
    'img with argument',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[img=text]https://flutter.dev/images/favicon.png[/img]');
      expect(result.toHtml(),
          '<div class="media img" data-src="https://flutter.dev/images/favicon.png"><i class="material-icons">&#xE410;</i><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div>');
    },
  );

  test(
    'url',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url]https://flutter.dev[/url]');
      expect(result.toHtml(),
          '<a href="https://flutter.dev">https:&#47;&#47;flutter.dev</a>');
    },
  );

  test(
    'url with argument',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url=https://flutter.dev]flutter[/url]');
      expect(result.toHtml(), '<a href="https://flutter.dev">flutter</a>');
    },
  );

  test(
    'url without argument but nested BB code ',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url]https://flutter.dev [b]text[/b][/url]');
      expect(result.toHtml(),
          '<strong>Ungültiger Link:<strong> &quot;https:&#47;&#47;flutter.dev [b]text[&#47;b]&quot;');
    },
  );

  test(
    'img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img][/url]');
      expect(result.toHtml(),
          '<div class="media img-link" data-src="https://flutter.dev/images/favicon.png" data-href="https://flutter.dev"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div>');
    },
  );

  test(
    'text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev]text [img]https://flutter.dev/images/favicon.png[/img] text[/url]');
      expect(result.toHtml(),
          '<a href="https://flutter.dev">text </a><div class="media img-link" data-src="https://flutter.dev/images/favicon.png" data-href="https://flutter.dev"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="https://flutter.dev"> text</a>');
    },
  );

  test(
    'left text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev]text [img]https://flutter.dev/images/favicon.png[/img][/url]');
      expect(result.toHtml(),
          '<a href="https://flutter.dev">text </a><div class="media img-link" data-src="https://flutter.dev/images/favicon.png" data-href="https://flutter.dev"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div>');
    },
  );

  test(
    'right text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img] text[/url]');
      expect(result.toHtml(),
          '<div class="media img-link" data-src="https://flutter.dev/images/favicon.png" data-href="https://flutter.dev"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="https://flutter.dev"> text</a>');
    },
  );

  test(
    'bold text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][b]bold text [img]https://flutter.dev/images/favicon.png[/img] bold text[/b][/url]');
      expect(result.toHtml(),
          '<a href="https://flutter.dev"><strong>bold text </strong></a><div class="media img-link" data-src="https://flutter.dev/images/favicon.png" data-href="https://flutter.dev"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="https://flutter.dev"><strong> bold text</strong></a>');
    },
  );

  test(
    'bold left text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][b]bold text [img]https://flutter.dev/images/favicon.png[/img][/b][/url]');
      expect(result.toHtml(),
          '<a href="https://flutter.dev"><strong>bold text </strong></a><div class="media img-link" data-src="https://flutter.dev/images/favicon.png" data-href="https://flutter.dev"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div>');
    },
  );

  test(
    'bold right text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][b][img]https://flutter.dev/images/favicon.png[/img] bold text[/b][/url]');
      expect(result.toHtml(),
          '<div class="media img-link" data-src="https://flutter.dev/images/favicon.png" data-href="https://flutter.dev"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="https://flutter.dev"><strong> bold text</strong></a>');
    },
  );

  test(
    'formatted text around img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][b]bold text[/b] [img]https://flutter.dev/images/favicon.png[/img] [u]underlined text[/u][/url]');
      expect(result.toHtml(),
          '<a href="https://flutter.dev"><strong>bold text</strong> </a><div class="media img-link" data-src="https://flutter.dev/images/favicon.png" data-href="https://flutter.dev"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="https://flutter.dev"> <u>underlined text</u></a>');
    },
  );

  test(
    'YouTube long URL',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[video]https://www.youtube.com/watch?v=fq4N0hgOWzU[/video]');
      expect(result.toHtml(),
          '<div class="media video yt" data-id="fq4N0hgOWzU"><i class="material-icons">&#xE02C;</i><button class="inline mdl-button mdl-js-button">Inline</button><button class="link mdl-button mdl-js-button">Youtube</button></div>');
    },
  );

  test(
    'YouTube short URL',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[video]https://youtu.be/fq4N0hgOWzU[/video]');
      expect(result.toHtml(),
          '<div class="media video yt" data-id="fq4N0hgOWzU"><i class="material-icons">&#xE02C;</i><button class="inline mdl-button mdl-js-button">Inline</button><button class="link mdl-button mdl-js-button">Youtube</button></div>');
    },
  );

  test(
    'YouTube embedded URL',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[video]https://www.youtube.com/embed/fq4N0hgOWzU[/video]');
      expect(result.toHtml(),
          '<div class="media video yt" data-id="fq4N0hgOWzU"><i class="material-icons">&#xE02C;</i><button class="inline mdl-button mdl-js-button">Inline</button><button class="link mdl-button mdl-js-button">Youtube</button></div>');
    },
  );

  test(
    'transform img to url',
    () {
      final BBCodeDocument result = transformImageToUrl(mdebbCodeParser
          .parse('[img]https://flutter.dev/images/favicon.png[/img]'));
      expect(result.toHtml(),
          '<a href="https://flutter.dev/images/favicon.png">https:&#47;&#47;flutter.dev&#47;images&#47;favicon.png</a>');
    },
  );

  test(
    'transform img to url in url',
    () {
      final BBCodeDocument result = transformImageToUrl(mdebbCodeParser.parse(
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img][/url]'));
      expect(result.toHtml(),
          '<a href="https://flutter.dev"><a href="https://flutter.dev/images/favicon.png">https:&#47;&#47;flutter.dev&#47;images&#47;favicon.png</a></a>');
    },
  );

  test(
    'transform img to url in url with text',
    () {
      final BBCodeDocument result = transformImageToUrl(mdebbCodeParser.parse(
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img] text[/url]'));
      expect(result.toHtml(),
          '<a href="https://flutter.dev"><a href="https://flutter.dev/images/favicon.png">https:&#47;&#47;flutter.dev&#47;images&#47;favicon.png</a> text</a>');
    },
  );

  test(
    'transform img to url in tags',
    () {
      final BBCodeDocument result = transformImageToUrl(mdebbCodeParser.parse(
          '[b]text [img]https://flutter.dev/images/favicon.png[/img] text[/b]'));
      expect(result.toHtml(),
          '<strong>text <a href="https://flutter.dev/images/favicon.png">https:&#47;&#47;flutter.dev&#47;images&#47;favicon.png</a> text</strong>');
    },
  );

  test(
    'no container tag',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse('[code]text[/code]');
      expect(result.toBBCode(), '[code]text[/code]');
    },
  );

  test(
    'no container tag missing closing',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse('[code]text');
      expect(result.toBBCode(), '[code]text[/code]');
    },
  );

  test(
    'no container tag in bold',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[b]bold [code]text[/b]');
      expect(result.toBBCode(), '[b]bold [code]text[/code][/b]');
    },
  );

  test(
    'bold in no container tag',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[code]text in [b]bold[/b][/code]');
      expect(result.toBBCode(), '[code]text in [b]bold[/b][/code]');
    },
  );

  test(
    'broken bold in no container tag',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[code]text in [b]bold[/code]');
      expect(result.toBBCode(), '[code]text in [b]bold[/code]');
    },
  );

  test(
    'bold tag inside quote',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[quote][b]text[/b][/quote]');
      expect(result.toBBCode(), '[quote][b]text[/b][/quote]');
    },
  );

  test(
    'bold tag inside quote with bold text',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[quote][b]text in [b]bold[/b][/b][/quote]');
      expect(result.toBBCode(), '[quote][b]text in [b]bold[/b][/b][/quote]');
    },
  );

  test(
    'quote with reference',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[quote=1,1,"[CSF]Omega"][b]text[/b][/quote]');
      expect(result.toBBCode(), '[quote=1,1,"[CSF]Omega"][b]text[/b][/quote]');
    },
  );

  test(
    'img',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[img]https://flutter.dev/images/favicon.png[/img]');
      expect(result.toBBCode(),
          '[img]https://flutter.dev/images/favicon.png[/img]');
    },
  );

  test(
    'img with argument',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[img=text]https://flutter.dev/images/favicon.png[/img]');
      expect(result.toBBCode(),
          '[img]https://flutter.dev/images/favicon.png[/img]');
    },
  );

  test(
    'url',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url]https://flutter.dev[/url]');
      expect(result.toBBCode(), '[url]https://flutter.dev[/url]');
    },
  );

  test(
    'url with argument',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url=https://flutter.dev]flutter[/url]');
      expect(result.toBBCode(), '[url=https://flutter.dev]flutter[/url]');
    },
  );

  test(
    'url without argument but nested BB code ',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url]https://flutter.dev [b]text[/b][/url]');
      expect(result.toBBCode(), '[url]https://flutter.dev [b]text[/b][/url]');
    },
  );

  test(
    'img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img][/url]');
      expect(result.toBBCode(),
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img][/url]');
    },
  );

  test(
    'text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev]text [img]https://flutter.dev/images/favicon.png[/img] text[/url]');
      expect(result.toBBCode(),
          '[url=https://flutter.dev]text [img]https://flutter.dev/images/favicon.png[/img] text[/url]');
    },
  );

  test(
    'left text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev]text [img]https://flutter.dev/images/favicon.png[/img][/url]');
      expect(result.toBBCode(),
          '[url=https://flutter.dev]text [img]https://flutter.dev/images/favicon.png[/img][/url]');
    },
  );

  test(
    'right text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img] text[/url]');
      expect(result.toBBCode(),
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img] text[/url]');
    },
  );

  test(
    'bold text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][b]bold text [img]https://flutter.dev/images/favicon.png[/img] bold text[/b][/url]');
      expect(result.toBBCode(),
          '[url=https://flutter.dev][b]bold text [img]https://flutter.dev/images/favicon.png[/img] bold text[/b][/url]');
    },
  );

  test(
    'bold left text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][b]bold text [img]https://flutter.dev/images/favicon.png[/img][/b][/url]');
      expect(result.toBBCode(),
          '[url=https://flutter.dev][b]bold text [img]https://flutter.dev/images/favicon.png[/img][/b][/url]');
    },
  );

  test(
    'bold right text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][b][img]https://flutter.dev/images/favicon.png[/img] bold text[/b][/url]');
      expect(result.toBBCode(),
          '[url=https://flutter.dev][b][img]https://flutter.dev/images/favicon.png[/img] bold text[/b][/url]');
    },
  );

  test(
    'formatted text around img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=https://flutter.dev][b]bold text[/b] [img]https://flutter.dev/images/favicon.png[/img] [u]underlined text[/u][/url]');
      expect(result.toBBCode(),
          '[url=https://flutter.dev][b]bold text[/b] [img]https://flutter.dev/images/favicon.png[/img] [u]underlined text[/u][/url]');
    },
  );

  test(
    'YouTube long URL',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[video]https://www.youtube.com/watch?v=fq4N0hgOWzU[/video]');
      expect(result.toBBCode(),
          '[video]https://www.youtube.com/watch?v=fq4N0hgOWzU[/video]');
    },
  );

  test(
    'YouTube short URL',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[video]https://youtu.be/fq4N0hgOWzU[/video]');
      expect(result.toBBCode(), '[video]https://youtu.be/fq4N0hgOWzU[/video]');
    },
  );

  test(
    'YouTube embedded URL',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[video]https://www.youtube.com/embed/fq4N0hgOWzU[/video]');
      expect(result.toBBCode(),
          '[video]https://www.youtube.com/embed/fq4N0hgOWzU[/video]');
    },
  );

  test(
    'transform img to url',
    () {
      final BBCodeDocument result = transformImageToUrl(mdebbCodeParser
          .parse('[img]https://flutter.dev/images/favicon.png[/img]'));
      expect(result.toBBCode(),
          '[url]https://flutter.dev/images/favicon.png[/url]');
    },
  );

  test(
    'transform img to url in url',
    () {
      final BBCodeDocument result = transformImageToUrl(mdebbCodeParser.parse(
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img][/url]'));
      expect(result.toBBCode(),
          '[url=https://flutter.dev][url]https://flutter.dev/images/favicon.png[/url][/url]');
    },
  );

  test(
    'transform img to url in url with text',
    () {
      final BBCodeDocument result = transformImageToUrl(mdebbCodeParser.parse(
          '[url=https://flutter.dev][img]https://flutter.dev/images/favicon.png[/img] text[/url]'));
      expect(result.toBBCode(),
          '[url=https://flutter.dev][url]https://flutter.dev/images/favicon.png[/url] text[/url]');
    },
  );

  test(
    'transform img to url in tags',
    () {
      final BBCodeDocument result = transformImageToUrl(mdebbCodeParser.parse(
          '[b]text [img]https://flutter.dev/images/favicon.png[/img] text[/b]'));
      expect(result.toBBCode(),
          '[b]text [url]https://flutter.dev/images/favicon.png[/url] text[/b]');
    },
  );

  test(
    'transform document to quote',
    () {
      final BBCodeDocument result = transformDocumentToQuote(
          1, 1, '[CSF]Omega', mdebbCodeParser.parse('text [u]underlined[/u]'));
      expect(result.toBBCode(),
          '[quote=1,1,"[CSF]Omega"][b]text [u]underlined[/u][/b][/quote]');
    },
  );
}
