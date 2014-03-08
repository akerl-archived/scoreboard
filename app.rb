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

STATS_CACHE = BasicCache::TimeCache.new(lifetime: 900)

##
# Player definition for easier reuse below
class Player
  attr_reader :name, :stats

  def initialize(name)
    @name = name
    @stats = STATS_CACHE.cache(name) { GithubStats.new(name) }
  end

  def export
    { score: @stats.streak.length, today: @stats.streak.today }
  end
end

get '/:name/stats' do |name|
  headers 'Content-Type' => 'application/json'
  begin
    data = {
      user: name,
      stats: Player.new(name).export
    }
  rescue
    halt 500, '{}'
  end
  data.to_json
end

get '/:name/following' do |name|
  headers 'Content-Type' => 'application/json'
  begin
    players = CLIENT.following(name).map { |x| x.login }
  rescue
    halt 500, '{}'
  end
  players.map do |player|
    data = { user: player }
    data[:stats] = Player.new(player).export if STATS_CACHE.include? player
    data
  end.to_json
end

get '/:name' do |name|
  @player_one_name = name
  if STATS_CACHE.include? name
    @player_one_stats = Player.new(name).export.to_json
  end
  @title = "Scoreboard for #{name}"
  erb :scoreboard
end

get '/' do
  redirect to("/#{CONFIG['username']}")
end
