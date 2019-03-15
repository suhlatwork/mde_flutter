import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

import 'mde_account.dart';
import 'mde_codec.dart';
import 'mde_exceptions.dart';

class _XmlTrimmer extends xml.XmlVisitor {
  @override
  void visitDocument(xml.XmlDocument node) => _trim(node.children);

  @override
  void visitDocumentFragment(xml.XmlDocumentFragment node) =>
      _trim(node.children);

  @override
  void visitElement(xml.XmlElement node) => _trim(node.children);

  void _trim(List<xml.XmlNode> children) {
    for (var i = 0; i < children.length; ++i) {
      final node = children[i];
      if (node.nodeType == xml.XmlNodeType.TEXT && node.text.trim().isEmpty) {
        children[i] = xml.XmlText('');
      }
    }
    children.forEach(visit);
  }
}

class BookmarkItem {
  final int bookmarkId;
  final int postId;
  final String removeBookmarkToken;
  final bool threadClosed;
  final int threadId;
  final String threadTitle;
  final int unreadPosts;

  BookmarkItem({
    @required this.bookmarkId,
    @required this.postId,
    @required this.removeBookmarkToken,
    @required this.threadClosed,
    @required this.threadId,
    @required this.threadTitle,
    @required this.unreadPosts,
  });
}

class Bookmarks {
  Completer<List<BookmarkItem>> bookmarkListCompleter =
      Completer<List<BookmarkItem>>();

  Bookmarks() {
    _fetchBookmarks();
  }

  _fetchBookmarks() async {
    debugPrint(Uri.http(
      'forum.mods.de',
      'bb/xml/bookmarks.php',
    ).toString());

    final Cookie sessionCookie = await MDEAccount.sessionCookie();

    // if no user is logged in, leave early
    if (sessionCookie == null) {
      bookmarkListCompleter.complete(List<BookmarkItem>());
      return;
    }

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(
      Uri.http(
        'forum.mods.de',
        'bb/xml/bookmarks.php',
      ),
    );
    if (sessionCookie != null) {
      request.cookies.add(sessionCookie);
    }
    HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      // update session cookie
      if (sessionCookie != null) {
        // keep the last cookie for MDESID
        Cookie cookie = response.cookies.lastWhere((Cookie cookie) {
          return cookie.name == 'MDESID';
        });

        await MDEAccount.updateSessionCookie(cookie);
      }

      // if the call to the server was successful, parse the XML
      // the mods.de server encodes the XML document in UTF-8, but does not
      // specify this in the HTTP header so that the http package uses latin1 for
      // the decoding causing trouble with umlauts
      // the XML document currently specifies UTF-8 so this is hard-coded here
      final xml.XmlDocument document =
          xml.parse(await response.transform(mdeXmlDecoder).join());

      // trim text nodes that can be trimmed to an empty string, ...
      _XmlTrimmer().visit(document);
      // ..., and remove empty text nodes
      document.normalize();

      // if not logged in, the rootElement is not 'bookmarks'
      if (document.rootElement.name.qualified == 'not-logged-in') {
        // outdated login information are stored somewhere
        MDEAccount.clearLoginInformation();

        bookmarkListCompleter.complete([]);
        return;
      }

      // the XML document should only contain one rootElement 'bookmarks'
      final xml.XmlElement bookmarks = document.rootElement;
      if (bookmarks.name.qualified != 'bookmarks') {
        throw XmlError.forBookmarks(
          error: 'Root element needs to be "bookmarks".',
        );
      }

      // the element 'bookmarks' should contain an attribute 'count' which should
      // be convertible to an integer, and should agree with the number of
      // children
      final int count = int.parse(bookmarks.getAttribute('count'));
      if (count is! int) {
        throw Exception('Unexpected content!');
      }
      if (count != bookmarks.children.length) {
        throw Exception('Inconsistent count!');
      }

      List<BookmarkItem> bookmarkList = List<BookmarkItem>();
      // loop over categories to get the individual boards
      for (final xml.XmlElement bookmark in bookmarks.children) {
        if (bookmark.name.qualified != 'bookmark') {
          throw XmlError.forBookmarks(
            error: 'All child elements of "bookmarks" should be "bookmark".',
          );
        }

        final int bookmarkId = int.parse(bookmark.getAttribute('BMID'));
        final int newPosts = int.parse(bookmark.getAttribute('newposts'));
        final int postId = int.parse(bookmark.getAttribute('PID'));

        var candidates = bookmark.findElements('thread');
        if (candidates.length != 1) {
          throw Exception('thread element missing from bookmark!');
        }
        final String threadName = candidates.first.text;

        final int threadId = int.parse(candidates.first.getAttribute('TID'));
        final bool threadClosed =
            int.parse(candidates.first.getAttribute('closed')) != 0;

        candidates = bookmark.findElements('token-removebookmark');
        if (candidates.length != 1) {
          throw Exception(
              'token-removebookmark element missing from bookmark!');
        }
        final String removeBookmarkToken =
            candidates.first.getAttribute('value');

        bookmarkList.add(
          BookmarkItem(
            bookmarkId: bookmarkId,
            postId: postId,
            removeBookmarkToken: removeBookmarkToken,
            threadClosed: threadClosed,
            threadTitle: threadName,
            threadId: threadId,
            unreadPosts: newPosts,
          ),
        );
      }

      bookmarkListCompleter.complete(bookmarkList);
    } else {
      response.drain();

      // If that call was not successful, throw an error.
      throw Exception('Failed to load bookmarks');
    }
  }
}
