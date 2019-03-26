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

  String toHtml(final String inner, final String argument);
}

class BBCodeBoldTag extends BBCodeTag {
  BBCodeBoldTag() : super('b');

  @override
  String toHtml(final String inner, final String argument) {
    return '<strong>$inner</strong>';
  }
}

class BBCodeUnderlineTag extends BBCodeTag {
  BBCodeUnderlineTag() : super('u');

  @override
  String toHtml(final String inner, final String argument) {
    return '<u>$inner</u>';
  }
}

class BBCodeItalicTag extends BBCodeTag {
  BBCodeItalicTag() : super('i');

  @override
  String toHtml(final String inner, final String argument) {
    return '<em>$inner</em>';
  }
}

class BBCodeListTag extends BBCodeTag {
  BBCodeListTag()
      : super('list', requiredChild: BBCodeListItemTag(), trimInner: true);

  @override
  String toHtml(final String inner, final String argument) {
    if (argument == '1') {
      return '<ol>$inner</ol>';
    }
    if (argument == 'a') {
      return '<ol type="a">$inner</ol>';
    }

    return '<ul>$inner</ul>';
  }
}

class BBCodeListItemTag extends BBCodeTag {
  BBCodeListItemTag() : super('*', closePrevious: true, trimInner: true);

  @override
  String toHtml(final String inner, final String argument) {
    return '<li>$inner</li>';
  }
}

class BBCodeTableTag extends BBCodeTag {
  BBCodeTableTag()
      : super('table', requiredChild: BBCodeTableRowTag(), trimInner: true);

  @override
  String toHtml(final String inner, final String argument) {
    String style = '';
    if (argument != null && argument.startsWith('border=')) {
      final int border = int.parse(argument.substring(7));
      style = ' style="--border: ${border}px;"';
    }
    return '<table$style>$inner</table>';
  }
}

class BBCodeTableRowTag extends BBCodeTag {
  BBCodeTableRowTag()
      : super('--',
            requiredChild: BBCodeTableColumnTag(),
            closePrevious: true,
            trimInner: true);

  @override
  String toHtml(final String inner, final String argument) {
    return '<tr>$inner</tr>';
  }
}

class BBCodeTableColumnTag extends BBCodeTag {
  BBCodeTableColumnTag() : super('||', closePrevious: true, trimInner: true);

  @override
  String toHtml(final String inner, final String argument) {
    return '<td>$inner</td>';
  }
}
