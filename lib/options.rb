require 'octokit'
require 'faraday-http-cache'
require 'basiccache'
require 'redisstore'

##
# Set Octokit to use caching
Octokit.middleware = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end

##
# Config object

CACHE_STORES = {
  'default' => BasicCache::Store,
  'null' => BasicCache::NullStore,
  'redis' => RedisStore::Store
}

DEFAULT_OPTIONS = {
  store: 'default'
}

##
# Define options for application
class Options
  attr_reader :username, :cache, :client

  def initialize(options = {})
    @options = options.merge DEFAULT_OPTIONS
    @username = @options[:username]
    @cache = _cache
    @client = _client
  end

  private

  def _cache
    unless CACHE_STORES[@options[:store]]
      fail "Store backend not found: #{@options[:store]}"
    end
    store = CACHE_STORES[@options[:store]].new @options[:storeopts]
    BasicCache::TimeCache.new(lifetime: 900, store: store)
  end

  def _client
    Octokit::Client.new(
      login: @options[:username],
      password: @options[:password],
      auto_paginate: true
    )
  end
end
