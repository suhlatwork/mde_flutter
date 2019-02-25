import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'package:reflected_mustache/mustache.dart';

import 'mde_exceptions.dart';
import 'mde_icons.dart';
import 'template_filler.dart';

class Board with TemplateFiller {
  final String templateFile = 'assets/board.html';

  final int boardId;
  final int boardPage;

  Board({@required this.boardId, @required this.boardPage}) {
    _fetchBoard();
  }

  _fetchBoard() async {
    debugPrint(Uri.http('forum.mods.de', 'bb/xml/board.php', {
      'BID': boardId.toString(),
      'page': boardPage.toString(),
    }).toString());

    final http.Response response =
        await http.get(Uri.http('forum.mods.de', 'bb/xml/board.php', {
      'BID': boardId.toString(),
      'page': boardPage.toString(),
    }));

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the XML
      // the mods.de server encodes the XML document in UTF-8, but does not
      // specify this in the HTTP header so that the http package uses latin1 for
      // the decoding causing trouble with umlauts
      // the XML document currently specifies UTF-8 so this is hard-coded here
      final xml.XmlDocument document =
          xml.parse(utf8.decode(response.bodyBytes));

      Map<String, Object> boardInfo = {
        'pages': (LambdaContext context) {
          final int nrPages = int.parse(context.renderString());
          if (nrPages == 1) {
            return 'Seite';
          } else {
            return 'Seiten';
          }
        },
        'replies': (LambdaContext context) {
          final int nrReplies = int.parse(context.renderString());
          if (nrReplies == 1) {
            return 'Beitrag';
          } else {
            return 'Beiträge';
          }
        },
        'boardId': boardId,
        'threads': [],
      };

      // the XML document should only contain one rootElement 'board'
      final xml.XmlElement board = document.rootElement;
      if (board.name.qualified != 'board') {
        throw Exception('Unexpected content!');
      }

      // the element 'board' should contain an element 'name'
      var candidates = board.findElements('name');
      if (candidates.length != 1) {
        throw Exception('name element missing from board!');
      }
      final String boardName = candidates.first.text;
      boardInfo['boardTitle'] = boardName;

      // the element 'board' should contain an element 'threads'
      candidates = board.findElements('threads');
      if (candidates.length != 1) {
        throw Exception('threads element missing from board!');
      }
      final xml.XmlElement threads = candidates.first;

      boardInfo['boardPage'] = int.parse(threads.getAttribute('page'));

      if (int.parse(threads.getAttribute('count')) == 0) {
        content.completeError(EmptyBoardPage(
            boardId: boardId,
            boardName: boardName,
            boardPage: boardInfo['boardPage']));
        return;
      }

      // loop over categories to get the individual boards
      for (final xml.XmlElement thread in threads.children) {
        Map<String, Object> threadInfo = {};

        final int threadId = int.parse(thread.getAttribute('id'));
        threadInfo['id'] = threadId;

        var candidates = thread.findElements('title');
        if (candidates.length != 1) {
          throw Exception('title element missing from thread!');
        }
        final String title = candidates.first.text;
        threadInfo['title'] = title;

        candidates = thread.findElements('subtitle');
        if (candidates.length != 1) {
          throw Exception('subtitle element missing from thread!');
        }
        final String subtitle = candidates.first.text;
        threadInfo['subtitle'] = subtitle;

        candidates = thread.findElements('number-of-replies');
        if (candidates.length != 1) {
          throw Exception('number-of-replies element missing from thread');
        }
        final int nrReplies = int.parse(candidates.first.getAttribute('value'));
        threadInfo['nrReplies'] = nrReplies;

        candidates = thread.findElements('number-of-pages');
        if (candidates.length != 1) {
          throw Exception('number-of-pages element missing from thread');
        }
        final int nrPages = int.parse(candidates.first.getAttribute('value'));
        threadInfo['nrPages'] = nrPages;

        candidates = thread.findElements('flags');
        if (candidates.length != 1) {
          throw Exception('flags element missing from thread');
        }
        final xml.XmlElement flags = candidates.first;

        candidates = flags.findElements('is-closed');
        if (candidates.length != 1) {
          throw Exception('is-closed element missing from flags');
        }
        final bool isClosed =
            int.parse(candidates.first.getAttribute('value')) == 1;
        threadInfo['isClosed'] = isClosed;

        candidates = flags.findElements('is-sticky');
        if (candidates.length != 1) {
          throw Exception('is-sticky element missing from flags');
        }
        final bool isSticky =
            int.parse(candidates.first.getAttribute('value')) == 1;
        threadInfo['isSticky'] = isSticky;

        candidates = flags.findElements('is-important');
        if (candidates.length != 1) {
          throw Exception('is-important element missing from flags');
        }
        final bool isImportant =
            int.parse(candidates.first.getAttribute('value')) == 1;
        threadInfo['isImportant'] = isImportant;

        candidates = flags.findElements('is-announcement');
        if (candidates.length != 1) {
          throw Exception('is-announcement element missing from flags');
        }
        final bool isAnnouncement =
            int.parse(candidates.first.getAttribute('value')) == 1;
        threadInfo['isAnnouncement'] = isAnnouncement;

        candidates = flags.findElements('is-global');
        if (candidates.length != 1) {
          throw Exception('is-global element missing from flags');
        }
        final bool isGlobal =
            int.parse(candidates.first.getAttribute('value')) == 1;
        threadInfo['isGlobal'] = isGlobal;

        candidates = thread.findElements('firstpost');
        if (candidates.length != 1) {
          throw Exception('firstpost element missing from thread!');
        }
        final xml.XmlElement firstPost = candidates.first;

        candidates = firstPost.findElements('post');
        if (candidates.length != 1) {
          throw Exception('post element missing from firstpost!');
        }
        final xml.XmlElement firstPostPost = candidates.first;

        // the element 'firstPostPost' should contain an element 'icon'
        candidates = firstPostPost.findElements('icon');
        if (candidates.length != 0) {
          if (candidates.length != 1) {
            throw Exception('icon element missing from post!');
          }
          final int id = int.parse(candidates.first.getAttribute('id'));
          threadInfo['icon'] = mdeIcons[id].threadIcon;
        } else {
          threadInfo['icon'] = '';
        }

        xml.XmlElement lastPost;
        xml.XmlElement lastPostPost;
        if (nrReplies == 0) {
          lastPost = firstPost;
          lastPostPost = firstPostPost;
        } else {
          candidates = thread.findElements('lastpost');
          if (candidates.length != 1) {
            throw Exception('lastpost element missing from thread!');
          }
          lastPost = candidates.first;

          candidates = lastPost.findElements('post');
          if (candidates.length != 1) {
            throw Exception('post element missing from firstpost/lastpost!');
          }
          lastPostPost = candidates.first;
        }

        candidates = lastPostPost.findElements('user');
        if (candidates.length != 1) {
          throw XmlError.forBoard(
              boardId: boardId,
              boardName: boardName,
              boardPage: boardInfo['boardPage'],
              error:
                  'A "post" element does not contain exactly one "name" child.');
        }
        final String lastPostUser = candidates.first.text;
        threadInfo['lastPostUser'] = lastPostUser;

        candidates = lastPostPost.findElements('date');
        if (candidates.length != 1) {
          throw XmlError.forBoard(
              boardId: boardId,
              boardName: boardName,
              boardPage: boardInfo['boardPage'],
              error:
                  'A "post" element does not contain exactly one "date" child.');
        }
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(
            int.parse(candidates.first.getAttribute('timestamp')) * 1000);
        final DateFormat dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
        final String lastPostDate = dateFormat.format(date);
        threadInfo['lastPostDate'] = lastPostDate;

        threadInfo['isSpecial'] = threadInfo['isAnnouncement'] ||
            threadInfo['isImportant'] ||
            threadInfo['isSticky'];

        List threads = boardInfo['threads'];
        threads.add(threadInfo);
      }

      content.complete(boardInfo);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
