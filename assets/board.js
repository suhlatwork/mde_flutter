function onPageShow() {
    appBarTitleSetter.postMessage($('div.board').attr('data-board-title'));
}

$(document).ready(function() {
    // check current user id
    checkUserId.postMessage(currentUserId);

    $('div.thread, div.thread-special').on('click', function() {
        var params = new URLSearchParams();
        params.set('TID', $(this).attr('data-thread-id'));

        var url = new URL('http://forum.mods.de/bb/thread.php');
        url.search = params;

        openUrl(url.toString());
        return false;
    });

    $('div.thread, div.thread-special').on('taphold', function() {
        var params = new URLSearchParams();
        params.set('TID', $(this).attr('data-thread-id'));
        params.set('page', $(this).attr('data-number-of-pages'));

        var url = new URL('http://forum.mods.de/bb/thread.php');
        url.search = params;

        openUrl(url.toString());
        return false;
    });

    $(document).on('swiperight', function(e) {
        if ($('div.board').attr('data-page') == 1) {
            return;
        }

        var params = new URLSearchParams();
        params.set('BID', $('div.board').attr('data-board-id'));
        params.set('page', Number($('div.board').attr('data-page')) - 1);

        var url = new URL('http://forum.mods.de/bb/board.php');
        url.search = params;

        openUrl(url.toString());
    });

    $(document).on('swipeleft', function(e) {
        var params = new URLSearchParams();
        params.set('BID', $('div.board').attr('data-board-id'));
        params.set('page', Number($('div.board').attr('data-page')) + 1);

        var url = new URL('http://forum.mods.de/bb/board.php');
        url.search = params;

        openUrl(url.toString());
    });

    // floating action button menu
    $('button.menu-item-refresh').on('click', function() {
        location.reload();
        return false;
    });

    $('button.menu-item-back').on('click', function() {
        window.history.back();
        return false;
    });

    $('button.menu').on('click', function() {
        $('button.menu-item').toggleClass('menu-item-hidden');
    });
});

function openUrl(url) {
    urlOpener.postMessage(url);
}
