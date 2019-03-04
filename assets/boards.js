function onPageShow() {
    appBarTitleSetter.postMessage('Forenübersicht');
}

$(document).ready(function() {
    // check current user id
    checkUserId.postMessage(currentUserId);

    $('div.category.category').on('click', function() {
        $(this).parent().children('div.board').toggle();
        return false;
    });

    $('div.board').on('click', function() {
        openUrl('http://forum.mods.de/bb/board.php?BID=' + $(this).attr('data-id'));
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
