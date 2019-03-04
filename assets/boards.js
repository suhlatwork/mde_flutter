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
});

function openUrl(url) {
    urlOpener.postMessage(url);
}
