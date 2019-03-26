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

import 'package:flutter/foundation.dart';

class EmptyBoardPage implements Exception {
  final int boardId;
  final String boardName;
  final int boardPage;

  EmptyBoardPage({
    @required this.boardId,
    @required this.boardName,
    @required this.boardPage,
  });

  @override
  String toString() {
    return 'No threads on page $boardPage for board "$boardName" with ID $boardId.';
  }
}

class EmptyThreadPage implements Exception {
  final int threadId;
  final String threadName;
  final int threadPage;

  EmptyThreadPage({
    @required this.threadId,
    @required this.threadName,
    @required this.threadPage,
  });

  @override
  String toString() {
    return 'No posts on page $threadPage for thread "$threadName" with ID $threadId.';
  }
}

class TooManyBookmarks implements Exception {
  @override
  String toString() {
    return 'Could not add a new bookmark, too many bookmarks already set.';
  }
}

class UnspecificBookmarkError implements Exception {
  @override
  String toString() {
    return 'Could not add or remove bookmark, received unspecific error from server.';
  }
}

class XmlError implements Exception {
  final String message;

  XmlError.forBoards({
    @required final String error,
  }) : message = 'Error in XML document for boards: $error';
  XmlError.forBoard({
    @required final int boardId,
    @required final String boardName,
    @required final int boardPage,
    @required final String error,
  }) : message =
            'Error in XML document for board $boardId ("$boardName") on page $boardPage: $error';
  XmlError.forBookmarks({
    @required final String error,
  }) : message = 'Error in XML document for bookmarks: $error';

  @override
  String toString() {
    return message;
  }
}
