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

// TODO: move to HTML/JS after https://github.com/flutter/flutter/issues/19718

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' show parse;

import 'mde_account.dart';
import 'mde_codec.dart';
import 'mde_icons.dart';
import 'post.dart';

enum _Type {
  postEdit,
  postNew,
  threadNew,
}

class PostEditor extends StatefulWidget {
  final String _appBarTitle;
  final _Type _type;

  final int boardId;
  final int threadId;
  final int postId;
  final String token;

  PostEditor.newThread({
    @required this.boardId,
    @required this.token,
  })  : _appBarTitle = "Neuer Thread",
        _type = _Type.threadNew,
        threadId = null,
        postId = null;

  PostEditor.editPost({
    @required this.threadId,
    @required this.postId,
    @required this.token,
  })  : _appBarTitle = "Beitrag bearbeiten",
        _type = _Type.postEdit,
        boardId = null;
  PostEditor.newPost({
    @required this.threadId,
    @required this.token,
    this.postId,
  })  : _appBarTitle = "Neuer Beitrag",
        _type = _Type.postNew,
        boardId = null;

  @override
  State<StatefulWidget> createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  Completer<String> _initialPostContent;
  Completer<int> _initialPostIcon;
  Completer<String> _initialPostTitle;
  Future<List> _initialValues;

  TextEditingController _controllerPostContent;
  TextEditingController _controllerPostTitle;
  TextEditingController _controllerThreadTitle;

  int _postIcon;

  @override
  initState() {
    super.initState();

    _controllerPostContent = TextEditingController();
    _controllerPostTitle = TextEditingController();
    _controllerThreadTitle = TextEditingController(
      text: '',
    );

    // initialized from the 'Completer's later on
    _postIcon = null;

    _initialPostContent = Completer<String>();
    _initialPostIcon = Completer<int>();
    _initialPostTitle = Completer<String>();
    _initialValues = Future.wait(
      [
        _initialPostContent.future.then((value) {
          _controllerPostContent.text = value;
        }),
        _initialPostIcon.future.then((value) {
          _postIcon = value;
        }),
        _initialPostTitle.future.then((value) {
          _controllerPostTitle.text = value;
        }),
      ],
    );

    switch (widget._type) {
      case _Type.postEdit:
        break;
      case _Type.postNew:
        _initialPostIcon.complete(0);
        _initialPostTitle.complete('');
        break;
      case _Type.threadNew:
        _initialPostIcon.complete(0);
        _initialPostTitle.complete('');
        break;
    }

    if (widget.postId != null) {
      _loadPost(widget._type, widget.threadId, widget.postId);
    } else {
      _initialPostContent.complete('');
    }
  }

  List<Widget> _buildTitlesPost(BuildContext context) {
    return <Widget>[
      Center(
        child: Text('Titel'),
      ),
      Padding(
        child: TextFormField(
          controller: _controllerPostTitle,
          maxLength: 65,
        ),
        padding: EdgeInsets.all(24),
      ),
    ];
  }

  List<Widget> _buildTitlesThread(BuildContext context) {
    return <Widget>[
      Center(
        child: Text('Titel'),
      ),
      Padding(
        child: TextFormField(
          controller: _controllerThreadTitle,
          maxLength: 65,
        ),
        padding: EdgeInsets.all(24),
      ),
      Center(
        child: Text('Untertitel'),
      ),
      Padding(
        child: TextFormField(
          controller: _controllerPostTitle,
          maxLength: 65,
        ),
        padding: EdgeInsets.all(24),
      ),
    ];
  }

  List<Widget> _buildTitles(BuildContext context) {
    switch (widget._type) {
      case _Type.postEdit:
      case _Type.postNew:
        return _buildTitlesPost(context);
      case _Type.threadNew:
        return _buildTitlesThread(context);
    }
    return null;
  }

  List<Widget> _buildIcons(BuildContext context) {
    ShapeDecoration decoActive = ShapeDecoration(
      color: Colors.purple,
      shape: CircleBorder(),
    );

    return <Widget>[
      Center(
        child: Text('Icon'),
      ),
      Wrap(
        alignment: WrapAlignment.center,
        children: mdeIcons
            .map((index, mdeIcon) {
              return MapEntry(
                index,
                Ink(
                  child: IconButton(
                    icon: Image(
                      image: AssetImage('assets/icons/${mdeIcon.fileName}'),
                    ),
                    onPressed: () {
                      setState(() {
                        _postIcon = index;
                      });
                    },
                  ),
                  decoration: ((_postIcon == index) ? decoActive : null),
                ),
              );
            })
            .values
            .toList()
              ..insert(
                0,
                Ink(
                  child: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        _postIcon = 0;
                      });
                    },
                  ),
                  decoration: ((_postIcon == 0) ? decoActive : null),
                ),
              ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._appBarTitle),
      ),
      body: Form(
        child: FutureBuilder(
          future: _initialValues,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView(
                children: _buildTitles(context) +
                    _buildIcons(context) +
                    <Widget>[
                      Center(
                        child: Text('Text'),
                      ),
                      Padding(
                        child: TextFormField(
                          buildCounter: (context,
                              {currentLength, maxLength, isFocused}) {
                            return null;
                          },
                          controller: _controllerPostContent,
                          maxLength: 15000,
                          maxLines: null,
                        ),
                        padding: EdgeInsets.all(24),
                      ),
                      FlatButton(
                          child: Text('Eintragen'),
                          onPressed: () {
                            Form.of(context).save();
                            _sendPost(context);
                          })
                    ],
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  _loadPost(final _Type type, final int threadId, final int postId) async {
    Post post = Post(threadId: threadId, postId: postId);

    if (type == _Type.postEdit) {
      post.postIcon.future.then((value) {
        _initialPostIcon.complete(value);
      });
      post.postTitle.future.then((value) {
        _initialPostTitle.complete(value);
      });
      post.postContent.future.then((value) {
        _initialPostContent.complete(value);
      });
    }
    if (type == _Type.postNew) {
      Future.wait([
        post.postAuthor.future,
        post.postContent.future,
      ]).then((values) {
        _initialPostContent
            .complete('''[quote=$threadId,$postId,"${values[0]}"][b]
${values[1]}
[/b][/quote]''');
      });
    }
  }

  _send(BuildContext context, final Uri url, Map arguments) async {
    final List<int> queryParameters = mdeCodec.encode(
      arguments.entries.fold(
        '',
        (prev, element) {
          prev += '&';
          prev += Uri.encodeQueryComponent(element.key, encoding: mdeCodec);
          prev += '=';
          prev += Uri.encodeQueryComponent(element.value.toString(),
              encoding: mdeCodec);

          return prev;
        },
      ),
    );
    final Cookie sessionCookie = await MDEAccount.sessionCookie();

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(
      url,
    );
    if (sessionCookie != null) {
      request.cookies.add(sessionCookie);
    }
    request.headers.contentType = ContentType(
        'application', 'x-www-form-urlencoded',
        charset: mdeCodec.name);
    request.add(queryParameters);
    HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      final html.Document document =
          parse(await response.transform(mdeCodec.decoder).join());

      final String title = document.querySelector('html head title').innerHtml;
      final bool successPost =
          (title == 'Antwort erstellt !' || title == 'Antwort editiert!');
      final bool successThread = (title == 'Thread erstellt !');

      if (successPost) {
        final String redirect =
            document.querySelectorAll('html head meta').firstWhere((element) {
          return element.attributes.containsKey('http-equiv') &&
              (element.attributes['http-equiv'] == 'refresh') &&
              element.attributes.containsKey('content');
        }).attributes['content'];
        final Uri redirectUrl =
            Uri.parse(redirect.substring(redirect.indexOf(';') + 1).trim());

        Navigator.pop(
          context,
          [
            int.parse(redirectUrl.queryParameters['TID']),
            int.parse(redirectUrl.queryParameters['PID']),
          ],
        );
      }

      if (successThread) {
        final String redirect =
            document.querySelectorAll('a.notice').firstWhere((element) {
          return element.innerHtml == 'Zu deinem Thread...';
        }).attributes['href'];
        final Uri redirectUrl = Uri.parse(redirect);

        Navigator.pop(
          context,
          [
            int.parse(redirectUrl.queryParameters['TID']),
          ],
        );
      }
    } else {
      response.drain();
    }

    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fehler beim Eintragen des Posts!',
        ),
      ),
    );
  }

  _sendPostEdit(BuildContext context) {
    return _send(
        context,
        Uri.http(
          'forum.mods.de',
          'bb/editreply.php',
        ),
        {
          'PID': widget.postId,
          'token': widget.token,
          'edit_title': _controllerPostTitle.text,
          'edit_icon': _postIcon,
          'message': _controllerPostContent.text,
          'edit_converturls': 1,
          'edit_disablebbcode': 0,
          'edit_disablesmilies': 0,
          'submit': 'Eintragen',
        });
  }

  _sendPostNew(BuildContext context) {
    _send(
        context,
        Uri.http(
          'forum.mods.de',
          'bb/newreply.php',
        ),
        {
          'TID': widget.threadId,
          'token': widget.token,
          'post_title': _controllerPostTitle.text,
          'post_icon': _postIcon,
          'message': _controllerPostContent.text,
          'post_converturls': 1,
          'post_disablebbcode': 0,
          'post_disablesmilies': 0,
          'submit': 'Eintragen',
        });
  }

  _sendThreadNew(BuildContext context) {
    return _send(
        context,
        Uri.http(
          'forum.mods.de',
          'bb/newthread.php',
        ),
        {
          'BID': widget.boardId,
          'token': widget.token,
          'thread_title': _controllerThreadTitle.text,
          'thread_subtitle': _controllerPostTitle.text,
          'thread_icon': _postIcon,
          'message': _controllerPostContent.text,
          'thread_converturls': 1,
          'thread_disablebbcode': 0,
          'thread_disablesmilies': 0,
          'submit': 'Eintragen',
        });
  }

  _sendPost(BuildContext context) {
    switch (widget._type) {
      case _Type.postEdit:
        _sendPostEdit(context);
        break;
      case _Type.postNew:
        _sendPostNew(context);
        break;
      case _Type.threadNew:
        _sendThreadNew(context);
        break;
    }
  }
}
