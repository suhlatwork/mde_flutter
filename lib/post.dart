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

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

import 'mde_account.dart';
import 'mde_codec.dart';
import 'mde_icons.dart';

class Post {
  final int threadId;
  final int postId;

  Completer<String> postAuthor;
  Completer<String> postTitle;
  Completer<int> postIcon;
  Completer<String> postContent;

  Post({
    @required this.threadId,
    @required this.postId,
  })  : postAuthor = Completer<String>(),
        postTitle = Completer<String>(),
        postIcon = Completer<int>(),
        postContent = Completer<String>() {
    _fetchPost();
  }

  _fetchPost() async {
    debugPrint(Uri.http(
      'forum.mods.de',
      'bb/xml/thread.php',
      {
        'TID': threadId.toString(),
        'onlyPID': postId.toString(),
      },
    ).toString());

    final Cookie sessionCookie = await MDEAccount.sessionCookie();

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.http(
      'forum.mods.de',
      'bb/xml/thread.php',
      {
        'TID': threadId.toString(),
        'onlyPID': postId.toString(),
      },
    ));
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

      // the XML document should only contain one rootElement 'board'
      final xml.XmlElement thread = document.rootElement;
      if (thread.name.qualified != 'thread') {
        throw Exception('Unexpected content!');
      }

      // the element 'thread' should contain an element 'posts'
      var candidates = thread.findElements('posts');
      if (candidates.length != 1) {
        throw Exception('posts element missing from thread!');
      }
      final xml.XmlElement posts = candidates.first;

      // ensure that at least one post was returned
      if (int.parse(posts.getAttribute('count')) == 0) {
        throw Exception('post not found');
      }

      // ensure that the requested post ID is actually returned
      xml.XmlElement post;
      for (final xml.XmlElement postChild in posts.children) {
        if (int.parse(postChild.getAttribute('id')) == postId) {
          post = postChild;
        }
      }
      if (post == null) {
        throw Exception('post not found');
      }

      // the element 'post' should contain an element 'user'
      candidates = post.findElements('user');
      if (candidates.length != 1) {
        throw Exception('user element missing from post!');
      }
      final xml.XmlElement user = candidates.first;
      postAuthor.complete(user.text);

      // the element 'post' should contain an element 'icon'
      candidates = post.findElements('icon');
      if (candidates.length != 0) {
        if (candidates.length != 1) {
          throw Exception('icon element missing from post!');
        }
        final int id = int.parse(candidates.first.getAttribute('id'));
        if (mdeIcons.containsKey(id)) {
          postIcon.complete(id);
        } else {
          postIcon.complete(0);
        }
      } else {
        postIcon.complete(0);
      }

      // the element 'post' should contain an element 'message'
      candidates = post.findElements('message');
      if (candidates.length != 1) {
        throw Exception('message element missing from post!');
      }
      final xml.XmlElement message = candidates.first;

      // the element 'message' should contain an element 'title'
      candidates = message.findElements('title');
      if (candidates.length != 1) {
        throw Exception('title element missing from message!');
      }
      postTitle.complete(candidates.first.text);

      // the element 'message' should contain an element 'content'
      candidates = message.findElements('content');
      if (candidates.length != 1) {
        throw Exception('content element missing from message!');
      }
      postContent.complete(candidates.first.text);
    } else {
      response.drain();

      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
