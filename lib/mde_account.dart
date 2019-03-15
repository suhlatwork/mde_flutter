import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';

import 'mde_codec.dart';
import 'mde_exceptions.dart';
import 'password_dialog.dart';

class MDEAccount {
  MDEAccount._();

  static addBookmark({
    @required final int postId,
    @required final String setBookmarkToken,
  }) async {
    final Cookie sessionCookie = await MDEAccount.sessionCookie();

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.http(
      'forum.mods.de',
      'bb/async/set-bookmark.php',
      {
        'PID': postId.toString(),
        'token': setBookmarkToken,
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

      final String reply = await response.transform(mdeXmlDecoder).join();
      final int result = int.parse(reply.split(RegExp(r'\s'))[0]);
      if (result == 1) {
        // success
        return;
      }
      if (result == 2) {
        // cannot add any more bookmarks
        throw TooManyBookmarks();
      }
    } else {
      response.drain();
    }

    throw UnspecificBookmarkError();
  }

  static clearLoginInformation({final Duration nextLoginDialog}) async {
    // invalidate cookie and user information in preferences
    Future<SharedPreferences> sharedPreferences =
        SharedPreferences.getInstance();
    await Future.wait(
      [
        sharedPreferences.then((sharedPreferences) {
          sharedPreferences.remove('username');
        }),
        sharedPreferences.then((sharedPreferences) {
          sharedPreferences.remove('userid');
        }),
        sharedPreferences.then((sharedPreferences) {
          sharedPreferences.remove('sessioncookie');
        }),
        sharedPreferences.then((sharedPreferences) {
          if (nextLoginDialog == null) {
            sharedPreferences.remove('next-login-dialog');
          } else {
            sharedPreferences.setString(
              'next-login-dialog',
              DateTime.now().add(nextLoginDialog).toString(),
            );
          }
        }),
      ],
    );
  }

  static Future<bool> login({
    @required final String username,
    @required final String password,
  }) async {
    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(
      Uri.http(
        'login.mods.de',
        '',
      ),
    );
    request.headers.contentType =
        ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
    request.add(
      utf8.encode(
        Uri(
          queryParameters: {
            'login_username': username,
            'login_password': password,
            'login_lifetime': '31536000', // one year
          },
        ).query,
      ),
    );
    HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      final html.Document document =
          parse(await response.transform(mdeCodec.decoder).join());
      final bool success =
          document.getElementsByClassName('box success').length == 1;
      final bool error =
          document.getElementsByClassName('box error').length == 1;

      if ((success && error) || (!success && !error)) {
        throw Exception(
            'Login page did contain neither "box success" nor "box error", or did contain both.');
      }

      if (success) {
        final html.Element div =
            document.getElementsByClassName('box success')[0];

        final html.Element iframe = div.getElementsByTagName('iframe')[0];
        final String src = iframe.attributes['src'];

        final Uri uri = Uri.parse(src);
        final int currentUserId = int.parse(uri.queryParameters['UID']);

        // next open the page behind src (http://forum.mods.de/SSO.php?...) to
        // get the correct cookie
        HttpClient httpClient = HttpClient();
        HttpClientRequest request = await httpClient.getUrl(Uri.parse(src));
        HttpClientResponse response = await request.close();
        response.drain();

        // keep the last cookie for MDESID
        Cookie cookie = response.cookies.lastWhere((Cookie cookie) {
          return cookie.name == 'MDESID';
        });

        // set cookie and user information in preferences
        Future<SharedPreferences> sharedPreferences =
            SharedPreferences.getInstance();
        await Future.wait(
          [
            sharedPreferences.then((sharedPreferences) {
              sharedPreferences.setString('username', username);
            }),
            sharedPreferences.then((sharedPreferences) {
              sharedPreferences.setInt('userid', currentUserId);
            }),
            sharedPreferences.then((sharedPreferences) {
              sharedPreferences.setString('sessioncookie', cookie.toString());
            }),
            sharedPreferences.then((sharedPreferences) {
              sharedPreferences.remove('next-login-dialog');
            }),
          ],
        );

        return true;
      }

      if (error) {
        clearLoginInformation();
        return false;
      }
    } else {
      response.drain();

      // If that call was not successful, throw an error.
      throw Exception('Failed to load login page');
    }

    return false;
  }

  static Future<bool> loginDialog(BuildContext context) async {
    List<String> loginInformation = await showDialog(
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PasswordDialog();
      },
      context: context,
    );

    if (loginInformation != null) {
      bool success = await MDEAccount.login(
        username: loginInformation[0],
        password: loginInformation[1],
      );

      if (success) {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Benutzer "${loginInformation[0]}" erfolgreich eingeloggt.',
            ),
          ),
        );
        return true;
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Benutzer "${loginInformation[0]}" konnte nicht eingeloggt werden.',
            ),
          ),
        );
      }
    } else {
      await MDEAccount.clearLoginInformation(
        nextLoginDialog: Duration(
          hours: 24,
        ),
      );
    }

    return false;
  }

  static Future<bool> logout() async {
    // get logout token
    final Cookie sessionCookie = await MDEAccount.sessionCookie();

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(
      Uri.http(
        'forum.mods.de',
        'bb/index.php',
      ),
    );
    if (sessionCookie != null) {
      request.cookies.add(sessionCookie);
    }
    HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      // if the call to the server was successful, parse the HTML
      final html.Document document =
          parse(await response.transform(mdeCodec.decoder).join());

      final Uri logoutUrl = Uri.parse(
          document.querySelectorAll('a').firstWhere((html.Element element) {
        if (!element.attributes.containsKey('href')) {
          return false;
        }

        if (!element.attributes['href']
            .startsWith('http://login.mods.de/logout/')) {
          return false;
        }

        return true;
      }).attributes['href']);

      // TODO test that UID is equal to the stored user id

      HttpClient logoutHttpClient = HttpClient();
      HttpClientRequest logoutRequest = await logoutHttpClient.getUrl(
        Uri.http(
          'login.mods.de',
          '/logout/',
          {
            'UID': (await MDEAccount.userId()).toString(),
            'a': logoutUrl.queryParameters['a'],
          },
        ),
      );
      HttpClientResponse logoutResponse = await logoutRequest.close();

      if (logoutResponse.statusCode == 200) {
        final html.Document logoutDocument =
            parse(await logoutResponse.transform(mdeCodec.decoder).join());

        final bool success =
            logoutDocument.getElementsByClassName('box success').length == 1;

        if (success) {
          MDEAccount.clearLoginInformation();
          return true;
        }
      } else {
        logoutResponse.drain();
      }
    } else {
      response.drain();
    }

    // finally clear settings from preferences
    MDEAccount.clearLoginInformation();
    // session on server could not be destroyed
    return false;
  }

  static removeBookmark({
    @required final int bookmarkId,
    @required final String removeBookmarkToken,
  }) async {
    final Cookie sessionCookie = await MDEAccount.sessionCookie();

    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.http(
      'forum.mods.de',
      'bb/async/remove-bookmark.php',
      {
        'BMID': bookmarkId.toString(),
        'token': removeBookmarkToken,
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

      final String reply = await response.transform(mdeXmlDecoder).join();
      final int result = int.parse(reply.split(RegExp(r'\s'))[0]);
      if (result == 1) {
        // success
        return;
      }
    } else {
      response.drain();
    }

    throw UnspecificBookmarkError();
  }

  static Future<Cookie> sessionCookie() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String sessionCookieString =
        sharedPreferences.getString('sessioncookie');
    if (sessionCookieString == null) {
      return null;
    }
    return Cookie.fromSetCookieValue(sessionCookieString);
  }

  static Future<bool> showLoginDialog() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String timestamp = sharedPreferences.getString('next-login-dialog');

    if (timestamp == null) {
      return true;
    }

    if (DateTime.parse(timestamp).difference(DateTime.now()).isNegative) {
      return true;
    }

    return false;
  }

  static updateSessionCookie(final Cookie sessionCookie) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        'sessioncookie', sessionCookie.toString());
  }

  static Future<int> userId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt('userid');
  }

  static Future<String> userName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('username');
  }
}
