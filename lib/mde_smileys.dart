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

import 'bbcode_emoji.dart';

class MDESmiley extends BBCodeEmoji {
  MDESmiley(final String code, final String fileName)
      : super(
          code,
          html: '<img src="/assets/icons/$fileName" alt="$code">',
        );
}

List<MDESmiley> mdeSmileys = [
  MDESmiley(
    '8|',
    'icon3.gif',
  ),
  MDESmiley(
    ':(',
    'icon12.gif',
  ),
  MDESmiley(
    ':)',
    'icon7.gif',
  ),
  MDESmiley(
    ':0:',
    'icon4.gif',
  ),
  MDESmiley(
    ':bang:',
    'banghead.gif',
  ),
  MDESmiley(
    ':confused:',
    'confused.gif',
  ),
  MDESmiley(
    ':D',
    'biggrin.gif',
  ),
  MDESmiley(
    ':eek:',
    'icon15.gif',
  ),
  MDESmiley(
    ':hm:',
    'hm.gif',
  ),
  MDESmiley(
    ':huch:',
    'freaked.gif',
  ),
  MDESmiley(
    ':mad:',
    'icon13.gif',
  ),
  MDESmiley(
    ':mata:',
    'mata.gif',
  ),
  MDESmiley(
    ':moo:',
    'smiley-pillepalle.gif',
  ),
  MDESmiley(
    ':o',
    'icon16.gif',
  ),
  MDESmiley(
    ':p',
    'icon2.gif',
  ),
  MDESmiley(
    ':roll:',
    'icon18.gif',
  ),
  MDESmiley(
    ':ugly:',
    'ugly.gif',
  ),
  MDESmiley(
    ':what:',
    'sceptic.gif',
  ),
  MDESmiley(
    ':wurgs:',
    'urgs.gif',
  ),
  MDESmiley(
    ':xx:',
    'icon11.gif',
  ),
  MDESmiley(
    ':zyklop:',
    'icon1.gif',
  ),
  MDESmiley(
    ':zzz:',
    'sleepy.gif',
  ),
  MDESmiley(
    ':|',
    'icon8.gif',
  ),
  MDESmiley(
    ';)',
    'wink.gif',
  ),
  MDESmiley(
    '^^',
    'icon5.gif',
  ),
];
