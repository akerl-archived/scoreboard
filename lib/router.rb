require 'lib/options'
require 'sinatra/base'
require 'mustache/sinatra'
require 'githubstats'
require 'json'

##
# The real deal, yo
class App < Sinatra::Base
  register Mustache::Sinatra
  require_relative '../views/layout.rb'

  ENV_OPTIONS = ENV.select { |x| x.match(/^SB_/) }.map do |k, v|
    [k[3..-1].downcase.to_sym, v]
  end.to_h

  OPTIONS = Options.new ENV_OPTIONS
  CACHE = OPTIONS.cache
  CLIENT = OPTIONS.client

  ROW_TEMPLATE = File.read('templates/row.mustache')

  helpers do
    def load_stats(name)
      CACHE.cache(name) do
        stats = GithubStats.new(name)
        {
          name: name,
          score: stats.streak.length || 0,
          today: stats.today != 0
        }
      end
    end

    def load_players(name)
      players = CACHE.cache('player#' + name) do
        CLIENT.following(name).map(&:login) << name
      end
      players.map { |p| CACHE.include?(p) ? load_stats(p) : { name: p } }
    end
  end

  set :mustache, views: 'views', templates: 'templates'

  get %r{/([\w-]+)/stats$} do |name|
    begin
      headers 'Content-Type' => 'application/json'
      load_stats(name).to_json
    rescue
      halt 500, '{}'
    end
  end

  get %r{^/([\w-]+)/following$} do |name|
    begin
      headers 'Content-Type' => 'application/json'
      load_players(name).to_json
    rescue
      halt 500, '{}'
    end
  end

  get %r{^/([\w-]+)$} do |name|
    @player_one = name
    @preload = CACHE.include?('player#' + name) ? load_players(name) : []
    @title = "Scoreboard for #{name}"
    mustache :scoreboard
  end

  get '/' do
    name = params[:name] || OPTIONS.default_user
    halt 500, mustache(:fail) unless name.match(/^[\w-]*$/)
    redirect to("/#{name}")
  end

  not_found do
    mustache :fail
  end

  error do
    mustache :fail
  end
end
