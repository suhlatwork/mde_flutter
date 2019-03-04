function onPageShow() {
    appBarTitleSetter.postMessage($('div.thread').attr('data-thread-title'));
}

$(document).ready(function() {
    // check current user id
    checkUserId.postMessage(currentUserId);

    // jump to post requested by the PID argument
    if (typeof initialAnchor !== 'undefined' && initialAnchor !== null) {
        var anchor = $('a[name="' + initialAnchor + '"]');
        if (anchor.length) {
            $('html, body').scrollTop(anchor.offset().top);
        }
    }

    // image (with link): link button
    $("div.img-link.media, div.gif-link.media").on("click", "button.link", function() {
        openUrl($(this).parent().attr('data-href'));
    });

    // image (with and without link): inline button
    $("div.img-link.media, div.gif-link.media, div.img.media, div.gif.media").on(
        "click", "button.inline", function() {
        replaceImage($(this).parent());
    });

    // image (with and without link): viewer button
    $("div.img-link.media, div.gif-link.media, div.img.media, div.gif.media").on(
        "click", "button.viewer", function() {
        openUrl($(this).parent().attr('data-src'));
    });

    // video: inline button
    $("div.video.media").on("click", "button.inline", function() {
        replaceVideo($(this).parent());
    });

    // video: viewer button
    $("div.video.media").on("click", "button.viewer", function() {
        openUrl($(this).parent().attr('data-src'));
    });

    // video: youtube button
    $("div.video.media").on("click", "button.link", function() {
        openUrl('https://youtu.be/' + $(this).parent().attr('data-id'));
    });

    $("div.spoiler button").click(function() {
        var p = $(this).parent();
        p.find("button,i").hide();
        p.css("display", "block");
        p.find('div.spoiler-content').show();
    });

    $('a.author').click(function() {
        var parameters = new URLSearchParams(this.search);
        var pid = parameters.get('PID');
        var anchor = $('a[name="' + pid + '"]');
        if (anchor.length) {
            $('html, body').scrollTop(anchor.offset().top);
            return false;
        }
    });

    $(document).on('click', 'a', function(e) {
        openUrl(this.href);
        return false;
    });

    $(document).on('swiperight', function(e) {
        if ($('div.thread').attr('data-page') == 1) {
            return;
        }

        var params = new URLSearchParams();
        params.set('TID', $('div.thread').attr('data-thread-id'));
        params.set('page', Number($('div.thread').attr('data-page')) - 1);

        var url = new URL('http://forum.mods.de/bb/thread.php');
        url.search = params;

        openUrl(url.toString());
    });

    $(document).on('swipeleft', function(e) {
        if ($('div.thread').attr('data-page') == $('div.thread').attr('data-number-of-pages')) {
            return;
        }

        var params = new URLSearchParams();
        params.set('TID', $('div.thread').attr('data-thread-id'));
        params.set('page', Number($('div.thread').attr('data-page')) + 1);

        var url = new URL('http://forum.mods.de/bb/thread.php');
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

function replaceImage(container) {
    var srcUrl = container.attr("data-src");
    var img = $('<img/>').attr('src', srcUrl).attr('alt', srcUrl);

    var hrefUrl = container.attr("data-href");
    if (typeof hrefUrl === "undefined") {
        container.replaceWith(img);
    } else {
        var a = $('<a/>').attr('href', hrefUrl).append(img);
        container.replaceWith(a);
    }
}

function replaceVideo(container) {
    if (container.hasClass("yt")) {
        var id = container.attr('data-id');
        var iframe = $('<iframe type="text/html" frameborder="0" allowfullscreen/>').attr('src', 'https://www.youtube.com/embed/' + id + '?fs=1');
        var wrapper = $('<div class="videoWrapper"/>').append(iframe);
        container.replaceWith(wrapper);
    } else {
        var srcUrl = container.attr('data-src');
        var wrapper = $('<video controls width="100%"/>').attr('src', srcUrl);
        container.replaceWith(wrapper);
    }
}
