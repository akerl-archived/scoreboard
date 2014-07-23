function handle_followers(data) {
    NProgress.configure({ trickle: false, showSpinner: false });
    NProgress.start();
    step = 100 / data.length;
    for (var i in data) add_player(data[i])
}

function add_player(data) {
    $.ajax({url:'/' + data.name + '/stats', success:create_row});
}

function create_row(data) {
    var scoreboard = $('#scoreboard');
    var tmp = Mustache.render(template, data);
    scoreboard.append(tmp);
}

function update_bar(element) {
    var size = element.attr('data-score') / max * element.width();
    $(element.children('.slider')[0]).css('left', size);
}

function resize_all_bars() {
    $('.bar').each(function() { update_bar($(this)) });
}

function sort_all_bars() {
    $('#players').divsort();
    $('#bars').divsort();
}

function update_all_bars() {
    sort_all_bars();
    resize_all_bars();
}

function build_scoreboard() {
    if (typeof preload === 'undefined') {
        $.ajax({url:'/' + player_one + '/following', success:handle_followers});
    } else if ( preload.length != 0 ) {
        handle_followers(preload);
    } else {
        update_all_bars();
    }
}

jQuery.fn.divsort = function() {
    $("> div", this[0]).sort(asc_sort).appendTo(this[0]);
    function asc_sort(a, b) {
        return ($(b).data("score")) > ($(a).data("score")) ? 1 : -1;
    }
}

$(document).ready(function() { build_scoreboard(); });
$(window).resize(function() { resize_all_bars(); });
$(document).ajaxStop(function() { NProgress.done(); update_all_bars(); });

