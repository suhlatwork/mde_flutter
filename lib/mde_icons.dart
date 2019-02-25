class MDEIcon {
  final String postIcon;
  final String threadIcon;

  MDEIcon(final String fileName, final String alternativeText)
      : postIcon =
            '<img class="posticon" src="/assets/icons/$fileName" alt="$alternativeText">',
        threadIcon =
            '<img src="/assets/icons/$fileName" alt="$alternativeText">';
}

class MDEBrokenIcon implements MDEIcon {
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
  55: MDEBrokenIcon(),
};
