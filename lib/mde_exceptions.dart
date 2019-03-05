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
