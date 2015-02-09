**Inactive Project:** Now that almost everybody I was working with ended their GitHub streaks, there's not much use putting further work into this.

scoreboard
=========

[![Dependency Status](https://img.shields.io/gemnasium/akerl/scoreboard.svg)](https://gemnasium.com/akerl/scoreboard)
[![Code Climate](https://img.shields.io/codeclimate/github/akerl/scoreboard.svg)](https://codeclimate.com/github/akerl/scoreboard)
[![Coverage Status](https://img.shields.io/coveralls/akerl/scoreboard.svg)](https://coveralls.io/r/akerl/scoreboard)
[![Build Status](https://img.shields.io/travis/akerl/scoreboard.svg)](https://travis-ci.org/akerl/scoreboard)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Sinatra app to show a user's Github streak compared to the people they follow.

## Usage

    git clone git://github.com/akerl/scoreboard
    cd scoreboard
    bundle install
    SB_DEFAULT=jimbo SB_TOKEN=5b1TQIDWNHbNdCqv9VrTybz thin start

To start a dev server, use shotgun (it reloads files after your changes):

    SB_DEFAULT=jimbo SB_TOKEN=5b1TQIDWNHbNdCqv9VrTybz shotgun

If you want to use the alternate Redis backend for local caching, set the SB\_STORE environment variable to "redis". If you have options to pass to Redis, set SB\_STOREOPTS to a JSON object of the options.

The Redis support uses [redisstore](https://github.com/akerl/redisstore), which in turn uses [redis-rb](https://github.com/redis/redis-rb).

## License

scoreboard is released under the MIT License. See the bundled LICENSE file for details.

All content in ./assets/ is used under its original license, which is included in that directory.

