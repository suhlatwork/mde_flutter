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

import 'package:mde_flutter/bbcode_parser.dart';

void main() {
  BBCodeParser bbCodeParser = BBCodeParser(
    [
      BBCodeBoldTag(),
      BBCodeUnderlineTag(),
      BBCodeListTag(),
      BBCodeListItemTag(),
      BBCodeTableTag(),
      BBCodeTableRowTag(),
      BBCodeTableColumnTag(),
    ],
    emojiParser: BBCodeEmojiParser(
      [
        BBCodeEmoji(
          ':)',
          html: '<img src="grin.gif">',
        ),
      ],
      [
        'b',
      ],
    ),
  );

  test(
    'text',
    () {
      final BBCodeDocument result = bbCodeParser.parse('text');
      expect(result.toHtml(), 'text');
    },
  );

  test(
    'bold tags',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[b]bold text[/b]');
      expect(result.toHtml(), '<strong>bold text</strong>');
    },
  );

  test(
    'bold tags with leading text',
    () {
      final BBCodeDocument result = bbCodeParser.parse('text [b]bold text[/b]');
      expect(result.toHtml(), 'text <strong>bold text</strong>');
    },
  );

  test(
    'bold tags with trailing text',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[b]bold text[/b] text');
      expect(result.toHtml(), '<strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with surrounding text',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b=123]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with two arguments',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b=123,456]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with quoted argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b="[csf]"]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with two quoted argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b="[ff]","[vv]"]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with number and quoted argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b=123,"[vv]"]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with quoted and numbered argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b="[vv]",123]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with two quoted and one numbered argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b="[vv]",123,"[ff]"]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with one quoted and two numbered argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b=456,"[vv]",123]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with argument in closing',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b]bold text[/b=456] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with named argument without value',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with named argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a=123]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with two named arguments',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a=123,b=456]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with two named arguments without values',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a,b]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with quoted named argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a="[csf]"]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with two quoted named argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a="[ff]",b="[vv]"]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with number and quoted named argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a=123,b="[vv]"]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with quoted and numbered named argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a="[vv]",b=123]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with two quoted and one numbered named argument',
    () {
      final BBCodeDocument result = bbCodeParser
          .parse('text [b a="[vv]",b=123,c="[ff]"]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with one quoted and two numbered named argument',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a=456,b="[vv]",c=123]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with one quoted and two numbered named argument partially without values',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b a,b="[vv]",c]bold text[/b] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'bold tags with named argument in closing',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('text [b]bold text[/b a=456] text');
      expect(result.toHtml(), 'text <strong>bold text</strong> text');
    },
  );

  test(
    'two bold tags',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[b]bold text[/b] text [b]bold text[/b]');
      expect(result.toHtml(),
          '<strong>bold text</strong> text <strong>bold text</strong>');
    },
  );

  test(
    'two neighboring bold tags',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[b]bold text[/b][b]bold text[/b]');
      expect(result.toHtml(),
          '<strong>bold text</strong><strong>bold text</strong>');
    },
  );

  test(
    'nested bold tags',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[b]bold [b]again[/b] text[/b]');
      expect(
          result.toHtml(), '<strong>bold <strong>again</strong> text</strong>');
    },
  );

  test(
    'bold and underline tags',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[b]bold[/b] [u]underline[/u] text');
      expect(result.toHtml(), '<strong>bold</strong> <u>underline</u> text');
    },
  );

  test(
    'nested bold and underline tags',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[b]bold [u]underline[/u] bold[/b]');
      expect(result.toHtml(), '<strong>bold <u>underline</u> bold</strong>');
    },
  );

  test(
    'broken nested bold and underline tags',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[b]bold [u]underline[/b] text[/u]');
      expect(
          result.toHtml(), '<strong>bold <u>underline</u></strong> text[/u]');
    },
  );

  test(
    'bold with nested closing underline tags',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[b]bold underline[/u] text[/b]');
      expect(result.toHtml(), '<strong>bold underline[/u] text</strong>');
    },
  );

  test(
    'bold and nested broken underline tags',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[b]bold [u]underline text[/b]');
      expect(result.toHtml(), '<strong>bold <u>underline text</u></strong>');
    },
  );

  test(
    'broken single bold tag at beginning',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[b]bold text');
      expect(result.toHtml(), '<strong>bold text</strong>');
    },
  );

  test(
    'broken single bold tag in the middle',
    () {
      final BBCodeDocument result = bbCodeParser.parse('text [b]bold');
      expect(result.toHtml(), 'text <strong>bold</strong>');
    },
  );

  test(
    'broken tag in the middle',
    () {
      final BBCodeDocument result = bbCodeParser.parse('text [b bold');
      expect(result.toHtml(), 'text [b bold');
    },
  );

  test(
    'open tag at the end',
    () {
      final BBCodeDocument result = bbCodeParser.parse('text[b]');
      expect(result.toHtml(), 'text<strong></strong>');
    },
  );

  test(
    'broken single closing bold tag at beginning',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[/b]bold text');
      expect(result.toHtml(), '[/b]bold text');
    },
  );

  test(
    'broken single closing bold tag in the middle',
    () {
      final BBCodeDocument result = bbCodeParser.parse('text[/b] bold');
      expect(result.toHtml(), 'text[/b] bold');
    },
  );

  test(
    'broken single closing bold tag at end',
    () {
      final BBCodeDocument result = bbCodeParser.parse('bold text[/b]');
      expect(result.toHtml(), 'bold text[/b]');
    },
  );

  test(
    'two open tags without closing',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[b]bold [u]underline');
      expect(result.toHtml(), '<strong>bold <u>underline</u></strong>');
    },
  );

  test(
    'unknown single tag at beginning',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[x]broken text');
      expect(result.toHtml(), '[x]broken text');
    },
  );

  test(
    'unknown single tag at end',
    () {
      final BBCodeDocument result = bbCodeParser.parse('broken text[x]');
      expect(result.toHtml(), 'broken text[x]');
    },
  );

  test(
    'unknown single tag in the middle',
    () {
      final BBCodeDocument result = bbCodeParser.parse('broken [x] text');
      expect(result.toHtml(), 'broken [x] text');
    },
  );

  test(
    'unknown closing single tag in the middle',
    () {
      final BBCodeDocument result = bbCodeParser.parse('broken [/x] text');
      expect(result.toHtml(), 'broken [/x] text');
    },
  );

  test(
    'unknown tags',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[x]broken text[/x]');
      expect(result.toHtml(), '[x]broken text[/x]');
    },
  );

  test(
    'emoji in bold tags',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[b]:)[/b]');
      expect(result.toHtml(), '<strong>:)</strong>');
    },
  );

  test(
    'emoji in underline tags',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[u]:)[/u]');
      expect(result.toHtml(), '<u><img src="grin.gif"></u>');
    },
  );

  test(
    'unordered list with closing tags',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[list][*]item 1[/*][*]item 2[/*][/list]');
      expect(result.toHtml(), '<ul><li>item 1</li><li>item 2</li></ul>');
    },
  );

  test(
    'unordered list',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[list][*]item 1[*]item 2[/list]');
      expect(result.toHtml(), '<ul><li>item 1</li><li>item 2</li></ul>');
    },
  );

  test(
    'ordered numeric list',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[list=1][*]item 1[*]item 2[/list]');
      expect(result.toHtml(), '<ol><li>item 1</li><li>item 2</li></ol>');
    },
  );

  test(
    'ordered alphabetic list',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[list=a][*]item 1[*]item 2[/list]');
      expect(
          result.toHtml(), '<ol type="a"><li>item 1</li><li>item 2</li></ol>');
    },
  );

  test(
    'unordered list with bold item',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[list][*][b]item 1[*]item 2[/b][/list]');
      expect(result.toHtml(),
          '<ul><li><strong>item 1</strong></li><li>item 2[/b]</li></ul>');
    },
  );

  test(
    'unordered list with closing tags not again opened',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[list][*]item 1[/*]item 2[/list]');
      expect(result.toHtml(), '<ul><li>item 1</li><li>item 2</li></ul>');
    },
  );

  test(
    'unordered list with closing tags not again opened and three items',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[list][*]item 1[/*]item 2[*]item 3[/list]');
      expect(result.toHtml(),
          '<ul><li>item 1</li><li>item 2</li><li>item 3</li></ul>');
    },
  );

  test(
    'unordered list without item tag',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[list]item 1[/list]');
      expect(result.toHtml(), '<ul><li>item 1</li></ul>');
    },
  );

  test(
    'unordered list without item tag and closing tag',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[list]item 1');
      expect(result.toHtml(), '<ul><li>item 1</li></ul>');
    },
  );

  test(
    'bold unordered list without item tag and closing tag',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[b][list]item 1');
      expect(result.toHtml(), '<strong><ul><li>item 1</li></ul></strong>');
    },
  );

  test(
    'empty unordered list',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[list][/list]');
      expect(result.toHtml(), '<ul></ul>');
    },
  );

  test(
    'empty unordered list without closing tag',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[list]');
      expect(result.toHtml(), '<ul></ul>');
    },
  );

  test(
    'item without list',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[*]item 1');
      expect(result.toHtml(), '[*]item 1');
    },
  );

  test(
    'items without list',
    () {
      final BBCodeDocument result = bbCodeParser.parse('[*]item 1[*]item 2');
      expect(result.toHtml(), '[*]item 1[*]item 2');
    },
  );

  test(
    'list with items with spaces',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[list][*] item 1 [*] item 2 [/list]');
      expect(result.toHtml(), '<ul><li>item 1</li><li>item 2</li></ul>');
    },
  );

  test(
    'list with bold items with spaces',
    () {
      final BBCodeDocument result = bbCodeParser
          .parse('[list][*][b] item 1[/b] [*] [b]item 2 [/b][/list]');
      expect(result.toHtml(),
          '<ul><li><strong> item 1</strong></li><li><strong>item 2 </strong></li></ul>');
    },
  );

  test(
    'list with bold and normal items with spaces',
    () {
      final BBCodeDocument result = bbCodeParser
          .parse('[list][*] item [b]bold[/b] 1 [*] item[b] bold [/b]2 [/list]');
      expect(result.toHtml(),
          '<ul><li>item <strong>bold</strong> 1</li><li>item<strong> bold </strong>2</li></ul>');
    },
  );

  test(
    'unordered list with new lines',
    () {
      final BBCodeDocument result = bbCodeParser.parse('''[list]
[*]item 1
[*]item 2
[/list]''');
      expect(result.toHtml(), '<ul><li>item 1</li><li>item 2</li></ul>');
    },
  );

  test(
    'table',
    () {
      final BBCodeDocument result =
          bbCodeParser.parse('[table] a [||] b [--] c [||] d [/table]');
      expect(result.toHtml(),
          '<table><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table>');
    },
  );

  test(
    'table with border=0',
    () {
      final BBCodeDocument result = bbCodeParser
          .parse('[table border=0] a [||] b [--] c [||] d [/table]');
      expect(result.toHtml(),
          '<table style="--border: 0px;"><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table>');
    },
  );
}
