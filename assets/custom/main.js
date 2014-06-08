function handle_followers(data) {
    size = data.length;
    counter = 0;
    for (var i in data) add_player(data[i]);
}

function add_player(data) {
    ('stats' in data) ? create_row(data) : $.ajax({url:'/' + data.user + '/stats', success:create_row});
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

    var row = document.createElement('div');
    row.className = 'player';
    row.setAttribute('data-name', user);
    row.setAttribute('data-score', score);

    new_element(row, 'span', 'name', user);
    new_element(row, 'i', 'fa fa-github-square', '');
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

$(document).ready(function(){
    NProgress.start();
    if (typeof preload === 'undefined') {
        $.ajax({url:'/' + player_one + '/following', success:handle_followers});
    } else {
        handle_followers(preload);
    }
});

