function handle_followers(data) {
    NProgress.configure({ trickle: false, showSpinner: false });
    NProgress.start();
    step = 100 / data.length;
    for (var i in data) add_player(data[i]);
}

function add_player(data) {
    $.ajax({url:'/' + data.user + '/stats', success:create_row});
}

function new_link(url, target, type, new_class, contents) {
    var link = $(document.createElement('a'));
    link.attr('href', url);
    new_element(link, type, new_class, contents);
    link.appendTo(target);
}

function new_element(target, type, new_class, contents) {
    var element = $(document.createElement(type));
    element.addClass(new_class);
    element.text(contents);
    element.appendTo(target);
}

function create_row(data) {
    var user = data.user;
    var score = data.score;
    var today = data.today;
    var player_div = $('#players');
    var bar_div = $('#bars');

    if (score > max) max = score;

    var player_row = $(document.createElement('div'));
    player_row.addClass('row player')
        .attr('data-name', user)
        .attr('data-score', score)
        .appendTo(player_div);
    new_element(player_row, 'span', 'score', score);
    new_link('https://github.com/' + user, player_row, 'i', 'fa fa-github-square', '');
    new_link('/' + user, player_row, 'span', 'name', user);

    var bar_row = $(document.createElement('div'));
    bar_row.addClass('row bar')
        .attr('data-name', user)
        .attr('data-score', score)
        .appendTo(bar_div);
    if (today == 1) new_element(bar_row, 'i', 'fa fa-check-square', '');
    new_element(bar_row, 'div', 'slider', '');

    NProgress.inc(step);
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

