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
  def initialize(params = {})
    @options = DEFAULT_OPTIONS.merge params
    unless CACHE_STORES[@options[:store]]
      fail "Store backend not found: #{@options[:store]}"
    end
  end

  def client
    @client ||= Octokit::Client.new(
      access_token: @options[:token],
      auto_paginate: true
    )
  end

  def cache
    @cache ||= BasicCache::TimeCache.new(lifetime: 900, store: store)
  end

  def default_user
    @options[:default] || 'akerl'
  end

  private

  def store
    @store ||= CACHE_STORES[@options[:store]].new JSON.load(@options[:storeopts])
  end
end
