import 'bbcode_emoji.dart';

class MDESmiley extends BBCodeEmoji {
  MDESmiley(final String code, final String fileName)
      : super(code,
            html: '<img src="/assets/icons/$fileName" alt="$code">');
}

List<MDESmiley> mdeSmileys = [
  MDESmiley('8|', 'icon3.gif'),
  MDESmiley(':(', 'icon12.gif'),
  MDESmiley(':)', 'icon7.gif'),
  MDESmiley(':0:', 'icon4.gif'),
  MDESmiley(':bang:', 'banghead.gif'),
  MDESmiley(':confused:', 'confused.gif'),
  MDESmiley(':D', 'biggrin.gif'),
  MDESmiley(':eek:', 'icon15.gif'),
  MDESmiley(':hm:', 'hm.gif'),
  MDESmiley(':huch:', 'freaked.gif'),
  MDESmiley(':mad:', 'icon13.gif'),
  MDESmiley(':mata:', 'mata.gif'),
  MDESmiley(':moo:', 'smiley-pillepalle.gif'),
  MDESmiley(':o', 'icon16.gif'),
  MDESmiley(':p', 'icon2.gif'),
  MDESmiley(':roll:', 'icon18.gif'),
  MDESmiley(':ugly:', 'ugly.gif'),
  MDESmiley(':what:', 'sceptic.gif'),
  MDESmiley(':wurgs:', 'urgs.gif'),
  MDESmiley(':xx:', 'icon11.gif'),
  MDESmiley(':zyklop:', 'icon1.gif'),
  MDESmiley(':zzz:', 'sleepy.gif'),
  MDESmiley(':|', 'icon8.gif'),
  MDESmiley(';)', 'wink.gif'),
  MDESmiley('^^', 'icon5.gif'),
];
