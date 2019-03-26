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
      expect(result.toHtml(), '<div class="code">text in [b]bold[/b]</div>');
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
    'img inside url',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url=link][img]image[/img][/url]');
      expect(result.toHtml(),
          '<div class="media img-link" data-src="image" data-href="link"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div>');
    },
  );

  test(
    'text and img inside url',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url=link]text [img]image[/img] text[/url]');
      expect(result.toHtml(),
          '<a href="link">text </a><div class="media img-link" data-src="image" data-href="link"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="link"> text</a>');
    },
  );

  test(
    'left text and img inside url',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url=link]text [img]image[/img][/url]');
      expect(result.toHtml(),
          '<a href="link">text </a><div class="media img-link" data-src="image" data-href="link"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div>');
    },
  );

  test(
    'right text and img inside url',
    () {
      final BBCodeDocument result =
          mdebbCodeParser.parse('[url=link][img]image[/img] text[/url]');
      expect(result.toHtml(),
          '<div class="media img-link" data-src="image" data-href="link"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="link"> text</a>');
    },
  );

  test(
    'bold text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[url=link][b]bold text [img]image[/img] bold text[/b][/url]');
      expect(result.toHtml(),
          '<a href="link"><strong>bold text </strong></a><div class="media img-link" data-src="image" data-href="link"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="link"><strong> bold text</strong></a>');
    },
  );

  test(
    'bold left text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[url=link][b]bold text [img]image[/img][/b][/url]');
      expect(result.toHtml(),
          '<a href="link"><strong>bold text </strong></a><div class="media img-link" data-src="image" data-href="link"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div>');
    },
  );

  test(
    'bold right text and img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser
          .parse('[url=link][b][img]image[/img] bold text[/b][/url]');
      expect(result.toHtml(),
          '<div class="media img-link" data-src="image" data-href="link"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="link"><strong> bold text</strong></a>');
    },
  );

  test(
    'formatted text around img inside url',
    () {
      final BBCodeDocument result = mdebbCodeParser.parse(
          '[url=link][b]bold text[/b] [img]image[/img] [u]underlined text[/u][/url]');
      expect(result.toHtml(),
          '<a href="link"><strong>bold text</strong> </a><div class="media img-link" data-src="image" data-href="link"><i class="material-icons">&#xE410;</i><button class="link mdl-button mdl-js-button">Link</button><button class="inline mdl-button mdl-js-button">Inline</button><button class="viewer mdl-button mdl-js-button">Viewer</button></div><a href="link"> <u>underlined text</u></a>');
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
}
