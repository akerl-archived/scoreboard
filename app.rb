require 'sinatra'
require 'octokit'
require 'faraday-http-cache'
require 'yaml'
require 'githubstats'
require 'basiccache'
require 'json'

CONFIG = YAML.load open('config.yaml').read
CLIENT = Octokit::Client.new(
  login: CONFIG['username'],
  password: CONFIG['password']
)

API_CACHE = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = API_CACHE

STATS = BasicCache::TimeCache.new(lifetime: 900)
PLAYERS = BasicCache::TimeCache.new(lifetime: 1800)

def load_stats(name)
  STATS.cache(name) do
    streak = GithubStats.new(name).streak
    today = streak.last && streak.last.date == Date.today ? 1 : 0
    { user: name, stats: { score: streak.length, today: today } }
  end
end

def load_players(name)
  players = PLAYERS.cache(name) { CLIENT.following(name).map(&:login) << name }
  players.map { |p| STATS.include?(p) ? load_stats(p) : { user: p } }
end

get '/:name/stats' do |name|
  begin
    headers 'Content-Type' => 'application/json'
    load_stats(name).to_json
  rescue
    halt 500, '{}'
  end
end

get '/:name/following' do |name|
  begin
    headers 'Content-Type' => 'application/json'
    load_players(name).to_json
  rescue
    halt 500, '{}'
  end
end

get '/:name' do |name|
  @player_one = name
  @preload = load_players(name).to_json if PLAYERS.include? name
  @title = "Scoreboard for #{name}"
  erb :scoreboard
end

get '/' do
  redirect to("/#{CONFIG['username']}")
end
