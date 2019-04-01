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

abstract class BBCodeTag {
  final String bbTag;
  final bool container;
  final BBCodeTag requiredChild;
  final bool closePrevious;
  final bool trimInner;

  BBCodeTag(this.bbTag,
      {this.container = true,
      this.requiredChild,
      this.closePrevious = false,
      this.trimInner = false});

  String toHtml(
      final dynamic argument, final String innerBBCode, final String innerHtml);

  String toBBCode(final dynamic argument, final String innerBBCode) {
    return '[$bbTag]$innerBBCode[/$bbTag]';
  }
}

class BBCodeBoldTag extends BBCodeTag {
  BBCodeBoldTag() : super('b');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<strong>$innerHtml</strong>';
  }
}

class BBCodeUnderlineTag extends BBCodeTag {
  BBCodeUnderlineTag() : super('u');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<u>$innerHtml</u>';
  }
}

class BBCodeItalicTag extends BBCodeTag {
  BBCodeItalicTag() : super('i');

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<em>$innerHtml</em>';
  }
}

class BBCodeListTag extends BBCodeTag {
  BBCodeListTag()
      : super('list', requiredChild: BBCodeListItemTag(), trimInner: true);

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    if (argument as String == '1') {
      return '<ol>$innerHtml</ol>';
    }
    if (argument as String == 'a') {
      return '<ol type="a">$innerHtml</ol>';
    }

    return '<ul>$innerHtml</ul>';
  }

  String toBBCode(final dynamic argument, final String innerBBCode) {
    String type = '';
    if (argument as String == '1') {
      type = '=1';
    }
    if (argument as String == 'a') {
      type = '=a';
    }

    return '[$bbTag$type]\n$innerBBCode[/$bbTag]';
  }
}

class BBCodeListItemTag extends BBCodeTag {
  BBCodeListItemTag() : super('*', closePrevious: true, trimInner: true);

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<li>$innerHtml</li>';
  }

  String toBBCode(final dynamic argument, final String innerBBCode) {
    return '[$bbTag]$innerBBCode\n';
  }
}

class BBCodeTableTag extends BBCodeTag {
  BBCodeTableTag()
      : super('table', requiredChild: BBCodeTableRowTag(), trimInner: true);

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    String style = '';
    if (argument != null && (argument as String).startsWith('border=')) {
      final int border = int.parse((argument as String).substring(7));
      style = ' style="--border: ${border}px;"';
    }
    return '<table$style>$innerHtml</table>';
  }

  String toBBCode(final dynamic argument, final String innerBBCode) {
    // remove first '[--]\n'
    if (innerBBCode.substring(0, 5) != '[${requiredChild.bbTag}]\n') {
      throw Error();
    }

    String style = '';
    if (argument != null && (argument as String).startsWith('border=')) {
      final int border = int.parse((argument as String).substring(7));
      style = ' border=$border';
    }

    return '[$bbTag$style]\n${innerBBCode.substring(5)}\n[/$bbTag]';
  }
}

class BBCodeTableRowTag extends BBCodeTag {
  BBCodeTableRowTag()
      : super('--',
            requiredChild: BBCodeTableColumnTag(),
            closePrevious: true,
            trimInner: true);

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<tr>$innerHtml</tr>';
  }

  String toBBCode(final dynamic argument, final String innerBBCode) {
    // remove first '[||]'
    if (innerBBCode.substring(0, 4) != '[${requiredChild.bbTag}]') {
      throw Error();
    }

    return '[$bbTag]\n${innerBBCode.substring(4)}';
  }
}

class BBCodeTableColumnTag extends BBCodeTag {
  BBCodeTableColumnTag() : super('||', closePrevious: true, trimInner: true);

  @override
  String toHtml(final dynamic argument, final String innerBBCode,
      final String innerHtml) {
    return '<td>$innerHtml</td>';
  }

  String toBBCode(final dynamic argument, final String innerBBCode) {
    return '[$bbTag]$innerBBCode';
  }
}
