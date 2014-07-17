require 'sinatra'
require 'octokit'
require 'faraday-http-cache'
require 'yaml'
require 'githubstats'
require 'basiccache'
require 'json'
require 'mustache'

CONFIG = {
  username: ENV['SB_USERNAME'],
  password: ENV['SB_PASSWORD'],
  backend: ENV['SB_BACKEND'],
  redis_opts: ENV['SB_REDIS']
}

CLIENT = Octokit::Client.new(
  login: CONFIG[:username],
  password: CONFIG[:password],
  auto_paginate: true
)

API_CACHE = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = API_CACHE

case CONFIG[:backend]
when nil
  STORE = BasicCache::Store.new
when 'redis'
  require 'redisstore'
  args = CONFIG[:redis_opts] ? JSON.parse(CONFIG[:redis_opts]) : {}
  STORE = RedisStore.new(args)
when 'null'
  STORE = BasicCache::NullStore.new
else
  fail "Unknown backend specified: #{CONFIG[:backend]}"
end

CACHE = BasicCache::TimeCache.new(lifetime: 900, store: STORE)

TEMPLATE = File.read('views/row.mustache')

class Row < Mustache
  attr_reader :name, :score, :today

  def initialize(params)
    @template = TEMPLATE
    @name = params[:name]
    @score = params[:score]
    @today = params[:today]
  end
end

def load_row(data)
  Row.new(data).render
end

def load_stats(name)
  CACHE.cache(name) do
    streak = GithubStats.new(name).streak
    today = streak.last && streak.last.date == Date.today
    { name: name, score: streak.length, today: today }
  end
end

def load_players(name)
  players = CACHE.cache('player#' + name) do
    CLIENT.following(name).map(&:login) << name
  end
  players.map { |p| CACHE.include?(p) ? load_stats(p) : { name: p } }
end

get %r{/([\w-]+)/stats$} do |name|
  begin
    name = params[:captures].first
    headers 'Content-Type' => 'application/json'
    load_stats(name).to_json
  rescue
    halt 500, '{}'
  end
end

get %r{^/([\w-]+)/following$} do |name|
  begin
    name = params[:captures].first
    headers 'Content-Type' => 'application/json'
    load_players(name).to_json
  rescue
    halt 500, '{}'
  end
end

get %r{^/([\w-]+)$} do |name|
  @player_one = params[:captures].first
  @preload = load_players(name) if CACHE.include? 'player#' + name
  @title = "Scoreboard for #{name}"
  erb :scoreboard
end

get '/' do
  name = params[:name] || CONFIG[:username]
  halt 500, erb(:fail) unless name.match '^[\w-]*$'
  redirect to("/#{name}")
end

not_found do
  erb :fail
end

error do
  erb :fail
end
