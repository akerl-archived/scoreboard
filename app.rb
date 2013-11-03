require 'sinatra'
require 'octokit'
require 'faraday-http-cache'
require 'yaml'
require 'github_stats'
require 'basic_cache'

Config = YAML.load open('config.yaml').read
Client = Octokit::Client.new :login => Config['username'], :password => Config['password']

API_Cache = Faraday::Builder.new do |builder|
    builder.use Faraday::HttpCache
    builder.use Octokit::Response::RaiseError
    builder.adapter Faraday.default_adapter
end
Octokit.middleware = API_Cache

Player = Struct.new(:name, :is_self?, :stats)
Stats_Cache = Basic_Cache::Time_Cache.new(900)

get %r{^/([a-zA-Z-]+)?$} do |name|
    name ||= Config['username']
    players = [
        Player.new(name, true),
        *Client.following(name).map { |x| Player.new(x.login, false) }
    ].map do |player|
        player.stats = Stats_Cache.cache(player.name) { Github_Stats.new(player.name) }
        player
    end.sort { |a, b| b.stats.streak.length <=> a.stats.streak.length }
    players.inject('') do |acc, x|
        acc << "#{x.name} has a streak of #{x.stats.streak.length}"
        acc << ", but has not committed today" if x.stats.today.zero?
        acc << "<br />\n"
    end
end

