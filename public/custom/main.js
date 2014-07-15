function handle_followers(data) {
    NProgress.configure({ trickle: false, showSpinner: false });
    NProgress.start();
    size = data.length;
    counter = 0;
    for (var i in data) add_player(data[i]);
}

function add_player(data) {
    ('stats' in data) ? create_row(data) : $.ajax({url:'/' + data.user + '/stats', success:create_row});
}

function new_link(url, target, type, new_class, contents) {
    var link = document.createElement('a');
    link.setAttribute('href', link);
    new_element(link, type, new_class, contents);
    target.appendChild(link);
}

function new_element(target, type, new_class, contents) {
    var element = document.createElement(type);
    element.className = new_class;
    element.textContent = contents;
    target.appendChild(element);
}

function create_row(data) {
    var user = data.user;
    var score = data.stats.score;
    var today = data.stats.today;
    var board = document.getElementById('scoreboard');

    if (score > max) {
        max = score;
    }

    var row = document.createElement('div');
    row.className = 'row player';
    row.setAttribute('data-name', user);
    row.setAttribute('data-score', score);

    new_element(row, 'span', 'bar', '');
    new_link('/' + user, row, 'span', 'name', user);
    new_link('https://github.com/' + user, row, 'i', 'fa fa-github-square', '');
    new_element(row, 'span', 'score', score);

    if (today == 1) new_element(row, 'i', 'fa fa-check-square', '');

    var rows = board.getElementsByClassName('player');
    for ( var i = 0 ; i < rows.length ; i++ ) {
        if (parseInt(rows[i].getAttribute('data-score')) > score) continue;
        board.insertBefore(row, rows[i]);
        return;
    }
    board.appendChild(row);
    NProgress.inc(100 / size);
    counter++;
    if (counter = size) NProgress.done();
}

function update_bar(element) {
    //var size = element.getAttribute('data-score') / max * element.clientWidth;
    var size = element.clientWidth;
    var bar = element.getElementsByClassName('bar')[0];
    bar.style.left = size + 'px';
}

function update_all_bars() {
    var players = $('.player');
    var length = players.length;
    for (i = 0; i < length; i++) {
        update_bar(players[i]);
    }
}

$(document).ready(function(){
    if (typeof preload === 'undefined') {
        $.ajax({url:'/' + player_one + '/following', success:handle_followers});
    } else if ( preload.length != 0 ) {
        handle_followers(preload);
    }
    update_all_bars();
});

$(window).resize(function() {
    update_all_bars();
});
