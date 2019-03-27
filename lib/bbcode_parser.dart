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

import 'dart:math';
import 'package:meta/meta.dart';

import 'bbcode_tags.dart';
export 'bbcode_tags.dart';

import 'bbcode_emoji.dart';
export 'bbcode_emoji.dart';

import 'bbcode_parts.dart';
export 'bbcode_parts.dart';

class _BBCodeParseState {
  final String bbCode;
  int _posConsumed;
  int _searchNextTag;
  List openTags;
  List<BBCodePart> parts;

  _BBCodeParseState(this.bbCode)
      : _posConsumed = 0,
        _searchNextTag = 0,
        openTags = List(),
        parts = List<BBCodePart>();

  int get posConsumed => _posConsumed;
  set posConsumed(int value) {
    if (value < _posConsumed) {
      throw RangeError.range(value, _posConsumed, null, 'posConsumed');
    }

    _posConsumed = value;
    if (value > _searchNextTag) {
      _searchNextTag = value;
    }
  }

  int get searchNextTag => _searchNextTag;
  set searchNextTag(int value) {
    if (value < _searchNextTag) {
      throw RangeError.range(value, _searchNextTag, null, 'seachNextTag');
    }

    _searchNextTag = value;
  }

  List<String> openTagsAsStrings() {
    return openTags.map<String>((element) {
      return element[0].bbTag;
    }).toList();
  }
}

class _BBCodeTag {
  final int startIndex;
  final int endIndex;

  final bool closing;
  final BBCodeTag bbTag;
  final String argument;

  _BBCodeTag({
    @required this.closing,
    @required this.bbTag,
    @required this.argument,
    @required this.startIndex,
    @required this.endIndex,
  });
}

class BBCodeParser {
  final List<BBCodeTag> _tags;
  final BBCodeEmojiParser emojiParser;
  final Function(BBCodePart) htmlPostProcessor;

  BBCodeParser(this._tags, {this.emojiParser, this.htmlPostProcessor});

  _BBCodeTag _parseBBCodeTag(
      _BBCodeParseState parseState, final int startIndex, final int endIndex) {
    if ((endIndex - startIndex) == 2) {
      return null;
    }

    // exclude brackets
    final String fullTag =
        parseState.bbCode.substring(startIndex + 1, endIndex - 1);

    final bool closing = fullTag.substring(0, 1) == '/';

    // find first space or equal sign
    final int startArgument = min(
        fullTag.indexOf(' ') == -1
            ? fullTag.indexOf('=')
            : fullTag.indexOf(' '),
        fullTag.indexOf('=') == -1
            ? fullTag.indexOf(' ')
            : fullTag.indexOf('='));
    final String tag = fullTag
        .substring(closing ? 1 : 0,
            (startArgument == -1) ? fullTag.length : startArgument)
        .toLowerCase();

    final String argument =
        (startArgument == -1) ? null : fullTag.substring(startArgument + 1);

    try {
      BBCodeTag bbTag = _tags.singleWhere((element) {
        return tag == element.bbTag;
      });

      return _BBCodeTag(
          closing: closing,
          bbTag: bbTag,
          argument: argument,
          startIndex: startIndex,
          endIndex: endIndex);
    } on StateError {
      // not a valid tag
      return null;
    }
  }

  _BBCodeTag _parseNextTag(_BBCodeParseState parseState,
      {bool updateState = true}) {
    // use a local copy, this function might also be called just to check, but
    // not to consume the next tag
    int searchNextTag = parseState.searchNextTag;

    while (searchNextTag < parseState.bbCode.length) {
      // find next open bracket
      final int open = parseState.bbCode.indexOf('[', searchNextTag);
      if (open == -1) {
        // no further tags
        break;
      }
      // next iteration of searching for a valid tag should start after this
      // bracket
      searchNextTag = open + 1;
      if (updateState) {
        parseState.searchNextTag = searchNextTag;
      }

      int close = parseState.bbCode.indexOf(']', open + 1);
      if (close == -1) {
        // no further complete tags
        break;
      }

      // search for a space or an equal sign indicating arguments. if a closing
      // bracket is found before this character, then this is not an argument to
      // the current tag
      final int equal = parseState.bbCode.indexOf('=', open + 1);
      if (equal != -1 && equal < close) {
        // search for a quote. if a quote is found before the next closing
        // bracket, then search for pairs of opening and closing ones
        int openingQuote =
            (parseState.bbCode.indexOf(RegExp(r'[=,]\s*"'), equal) == -1)
                ? -1
                : parseState.bbCode.indexOf('"', equal);
        while (openingQuote != -1 && openingQuote < close) {
          final int closingQuote =
              parseState.bbCode.indexOf(RegExp(r'"[,\]]\s*'), openingQuote + 1);
          if (closingQuote != -1) {
            openingQuote = (parseState.bbCode
                        .indexOf(RegExp(r'[=,]\s*"'), closingQuote + 1) ==
                    -1)
                ? -1
                : parseState.bbCode.indexOf('"', closingQuote + 1);
            close = parseState.bbCode.indexOf(']', closingQuote + 1);
          }
        }
      }

      _BBCodeTag tag = _parseBBCodeTag(parseState, open, close + 1);
      if (tag != null) {
        if (tag.bbTag.trimInner) {
          // check for whitespaces starting from tag.endIndex
          final String original = parseState.bbCode
              .substring(tag.endIndex, parseState.bbCode.length);
          final String trimmed = original.trimLeft();

          return _BBCodeTag(
              closing: tag.closing,
              bbTag: tag.bbTag,
              argument: tag.argument,
              startIndex: tag.startIndex,
              endIndex: tag.endIndex + original.length - trimmed.length);
        }
        return tag;
      }
    }

    return null;
  }

  BBCodePartText _parseCreateText(
      _BBCodeParseState parseState, final int startIndex, final int endIndex) {
    if (startIndex == endIndex) {
      return null;
    }

    final String text = parseState.bbCode.substring(startIndex, endIndex);

    BBCodeEmojiParser emojiParser;
    if (this.emojiParser != null) {
      if (this.emojiParser.parseInTags(parseState.openTagsAsStrings())) {
        emojiParser = this.emojiParser;
      }
    }

    return BBCodePartText(text, emojiParser);
  }

  _parseConsumeText(_BBCodeParseState parseState,
      {int endIndex, bool nextTagIsClosing: false}) {
    // default: consume full parseState.bbCode
    if (endIndex == null) {
      endIndex = parseState.bbCode.length;
    }

    int startIndexTrim = parseState.posConsumed;
    int endIndexTrim = endIndex;
    if (parseState.openTags.isNotEmpty &&
        parseState.openTags.last[0].trimInner) {
      if (parseState.parts.isEmpty) {
        final String original =
            parseState.bbCode.substring(startIndexTrim, endIndexTrim);
        final String trimmed = original.trimLeft();
        startIndexTrim += original.length - trimmed.length;
      }

      if (nextTagIsClosing) {
        final String original =
            parseState.bbCode.substring(startIndexTrim, endIndexTrim);
        final String trimmed = original.trimRight();
        endIndexTrim += trimmed.length - original.length;
      }
    }

    BBCodePartText textPart =
        _parseCreateText(parseState, startIndexTrim, endIndexTrim);
    if (textPart != null) {
      parseState.parts.add(textPart);
    }

    parseState.posConsumed = endIndex;
  }

  _parseCloseTags(_BBCodeParseState parseState, {int depth, int endIndex}) {
    // default: close all tags
    if (depth == null) {
      depth = 0;
    }

    while (parseState.openTags.length > depth) {
      _parseConsumeText(parseState, endIndex: endIndex, nextTagIsClosing: true);

      List<BBCodePart> innerParts = parseState.parts;

      final BBCodeTag bbTag = parseState.openTags.last[0];
      parseState.parts = parseState.openTags.last[1];
      final String argument = parseState.openTags.last[2];
      final int bbCodeStart = parseState.openTags.last[3];
      parseState.openTags.removeLast();

      String bbCode =
          parseState.bbCode.substring(bbCodeStart, parseState.posConsumed);
      if (bbTag.trimInner) {
        // left trim is taken into account via bbCodeStart
        bbCode = bbCode.trimRight();
      }

      parseState.parts.add(BBCodePart(
        bbTag,
        bbCode,
        innerParts,
        argument,
      ));
    }
  }

  BBCodeDocument parse(final String bbCode) {
    _BBCodeParseState parseState = _BBCodeParseState(bbCode);

    _BBCodeTag tag;
    while ((tag = _parseNextTag(parseState)) != null) {
      if (tag.closing) {
        // closing tag
        if (parseState.openTags.isNotEmpty) {
          final int depth = parseState.openTags.lastIndexWhere((element) {
            return element[0].bbTag == tag.bbTag.bbTag;
          });
          if (depth >= 0) {
            _parseCloseTags(parseState, depth: depth, endIndex: tag.startIndex);

            parseState.posConsumed = tag.endIndex;

            BBCodeTag requiredChild = parseState.openTags.isNotEmpty
                ? parseState.openTags.last[0].requiredChild
                : null;
            while (requiredChild != null) {
              _BBCodeTag nextTag =
                  _parseNextTag(parseState, updateState: false);

              if (nextTag != null) {
                // check if the next tag is the required one
                if (!nextTag.closing &&
                    nextTag.bbTag.bbTag == requiredChild.bbTag &&
                    parseState.bbCode.substring(
                            parseState.posConsumed, nextTag.startIndex) ==
                        '') {
                  parseState.openTags.add([
                    requiredChild,
                    parseState.parts,
                    null,
                    nextTag.endIndex,
                  ]);
                  parseState.parts = List<BBCodePart>();

                  parseState.posConsumed = nextTag.endIndex;
                } else if ((nextTag.bbTag.bbTag != requiredChild.bbTag ||
                        parseState.bbCode.substring(
                                parseState.posConsumed, nextTag.startIndex) !=
                            '') &&
                    !(nextTag.closing &&
                        nextTag.bbTag.bbTag ==
                            parseState.openTags.last[0].bbTag &&
                        parseState.bbCode.substring(
                                parseState.posConsumed, nextTag.startIndex) ==
                            '')) {
                  parseState.openTags.add([
                    requiredChild,
                    parseState.parts,
                    null,
                    parseState.posConsumed,
                  ]);
                  parseState.parts = List<BBCodePart>();
                }
              } else {
                // check if there is any text
                if (parseState.bbCode.substring(
                        parseState.posConsumed, parseState.bbCode.length) !=
                    '') {
                  parseState.openTags.add([
                    requiredChild,
                    parseState.parts,
                    null,
                    parseState.posConsumed,
                  ]);
                  parseState.parts = List<BBCodePart>();
                }
              }

              requiredChild = requiredChild.requiredChild;
            }
          }
        }
      } else {
        // check that the current tag may contain other tags
        if (parseState.openTags.isEmpty ||
            parseState.openTags.last[0].container == true) {
          if (tag.bbTag.closePrevious) {
            final int depth = parseState.openTags.lastIndexWhere((element) {
              return element[0].bbTag == tag.bbTag.bbTag;
            });
            if (depth >= 0) {
              _parseCloseTags(parseState,
                  depth: depth, endIndex: tag.startIndex);
            } else {
              // this tag is not valid here
              continue;
            }
          } else {
            _parseConsumeText(parseState, endIndex: tag.startIndex);
          }

          parseState.posConsumed = tag.endIndex;

          parseState.openTags.add([
            tag.bbTag,
            parseState.parts,
            tag.argument,
            parseState.posConsumed,
          ]);
          parseState.parts = List<BBCodePart>();

          BBCodeTag requiredChild = tag.bbTag.requiredChild;
          while (requiredChild != null) {
            _BBCodeTag nextTag = _parseNextTag(parseState, updateState: false);

            if (nextTag != null) {
              // check if the next tag is the required one
              if (!nextTag.closing &&
                  nextTag.bbTag.bbTag == requiredChild.bbTag &&
                  parseState.bbCode.substring(
                          parseState.posConsumed, nextTag.startIndex) ==
                      '') {
                parseState.openTags.add([
                  requiredChild,
                  parseState.parts,
                  null,
                  nextTag.endIndex,
                ]);
                parseState.parts = List<BBCodePart>();

                parseState.posConsumed = nextTag.endIndex;
              } else if ((nextTag.bbTag.bbTag != requiredChild.bbTag ||
                      parseState.bbCode.substring(
                              parseState.posConsumed, nextTag.startIndex) !=
                          '') &&
                  !(nextTag.closing &&
                      nextTag.bbTag.bbTag == tag.bbTag.bbTag &&
                      parseState.bbCode.substring(
                              parseState.posConsumed, nextTag.startIndex) ==
                          '')) {
                parseState.openTags.add([
                  requiredChild,
                  parseState.parts,
                  null,
                  parseState.posConsumed,
                ]);
                parseState.parts = List<BBCodePart>();
              }
            } else {
              // check if there is any text
              if (parseState.bbCode.substring(
                      parseState.posConsumed, parseState.bbCode.length) !=
                  '') {
                parseState.openTags.add([
                  requiredChild,
                  parseState.parts,
                  null,
                  parseState.posConsumed,
                ]);
                parseState.parts = List<BBCodePart>();
              }
            }

            requiredChild = requiredChild.requiredChild;
          }
        }
      }
    }

    if (parseState.openTags.isEmpty) {
      _parseConsumeText(parseState, nextTagIsClosing: true);
    } else {
      _parseCloseTags(parseState);
    }

    BBCodeDocument document = BBCodeDocument(bbCode, parseState.parts,
        htmlPostProcessor: htmlPostProcessor);

    return document;
  }
}
