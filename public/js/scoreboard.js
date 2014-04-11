function handle_followers(data) {
    for (var i in data) add_player(data[i]);
}

function add_player(data) {
    ('stats' in data) ? create_row(data) : $.ajax({url:'/' + data.user + '/stats', success:create_row});
}

function create_row(data) {
    var user = data.user;
    var score = data.stats.score;
    var board = document.getElementById('scoreboard');

    var new_row = document.createElement('div');
    new_row.className = 'player';
    new_row.setAttribute('data-name', user);
    new_row.setAttribute('data-score', score);

    var name_span = document.createElement('span');
    name_span.className = 'name';
    name_span.innerHTML = user;
    new_row.appendChild(name_span);

    var score_span = document.createElement('span');
    score_span.className = 'score';
    score_span.innerHTML = score;
    new_row.appendChild(score_span);

    var rows = board.getElementsByClassName('player');
    for ( var i = 0 ; i < rows.length ; i++ ) {
        if (parseInt(rows[i].getAttribute('data-score')) > score)
            continue;
        board.insertBefore(new_row, rows[i]);
        return;
    }
    board.appendChild(new_row);
}

$(document).ready(function(){
    if (typeof preload === 'undefined') {
        $.ajax({url:'/' + player_one + '/following', success:handle_followers});
    } else {
        handle_followers(preload);
    }
});

