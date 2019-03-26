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

class MDEIcon {
  final String fileName;

  final String postIcon;
  final String threadIcon;

  MDEIcon(this.fileName, final String alternativeText)
      : postIcon =
            '<img class="posticon" src="/assets/icons/$fileName" alt="$alternativeText">',
        threadIcon =
            '<img src="/assets/icons/$fileName" alt="$alternativeText">';
}

class MDEBrokenIcon implements MDEIcon {
  final String fileName = null;
  final String postIcon = '<i class="material-icons">&#xe3ad;</i>';
  final String threadIcon = '<i class="material-icons">&#xe3ad;</i>';
}

final Map<int, MDEIcon> mdeIcons = {
  1: MDEIcon(
    'thumbsdown.gif',
    'Thumbs down',
  ),
  2: MDEIcon(
    'thumbsup.gif',
    'Thumbs Up',
  ),
  28: MDEIcon(
    'icon9.gif',
    'Fragezeichen',
  ),
  32: MDEIcon(
    'icon2.gif',
    'zunge',
  ),
  33: MDEIcon(
    'icon3.gif',
    'unglaeubig',
  ),
  34: MDEIcon(
    'icon4.gif',
    'verschmitzt',
  ),
  35: MDEIcon(
    'icon5.gif',
    'froehlich',
  ),
  36: MDEIcon(
    'icon6.gif',
    'betruebt',
  ),
  37: MDEIcon(
    'icon7.gif',
    'amuesiert',
  ),
  38: MDEIcon(
    'icon8.gif',
    'missmutig',
  ),
  39: MDEIcon(
    'icon10.gif',
    'Ausrufezeichen',
  ),
  40: MDEIcon(
    'icon11.gif',
    'würg',
  ),
  41: MDEIcon(
    'icon12.gif',
    'traurig',
  ),
  42: MDEIcon(
    'icon13.gif',
    'böse',
  ),
  54: MDEIcon(
    'pfeil.gif',
    'Pfeil',
  ),
};
