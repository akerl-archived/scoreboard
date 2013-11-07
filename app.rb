require 'sinatra'
require 'octokit'
require 'faraday-http-cache'
require 'yaml'
require 'github_stats'
require 'basic_cache'
require 'json'

Config = YAML.load open('config.yaml').read
Client = Octokit::Client.new :login => Config['username'], :password => Config['password']

API_Cache = Faraday::Builder.new do |builder|
    builder.use Faraday::HttpCache
    builder.use Octokit::Response::RaiseError
    builder.adapter Faraday.default_adapter
end
Octokit.middleware = API_Cache

Stats_Cache = Basic_Cache::Time_Cache.new(900)

class Player
    attr_reader :name, :stats

    def initialize(name)
        @name = name
        @stats = Stats_Cache.cache(name) { Github_Stats.new(name) }
    end

    def export
        {
            :score => @stats.streak.length
        }
    end
end

get '/:name/stats' do |name|
    headers 'Content-Type' => 'application/json'
    begin
        data = {
            :user => name,
            :stats => Player.new(name).export
        }
    rescue
        halt 500, '{}'
    end
    data.to_json
end

get '/:name/following' do |name|
    headers 'Content-Type' => 'application/json'
    begin
        players = Client.following(name).map { |x| x.login }
    rescue
        halt 500, '{}'
    end
    players.map do |player|
        data = {:user => player}
        data[stats] = Player.new(name).export if Stats_Cache.include? player
        data
    end.to_json
end

get '/:name' do |name|
    @player_one = name
    @score = Stats_Cache.include? player ? Player.new(name).export : -1
    @title = "Scoreboard for #@player_one"
    erb :scoreboard
end

get '/' do
    redirect to("/#{Config['username']}")
end

