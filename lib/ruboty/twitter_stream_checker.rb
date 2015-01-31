require "ruboty"
require 'active_support'
require 'active_support/core_ext'
require "ruboty/handlers/twitter_stream_checker"
require "ruboty/twitter_stream_checker/job"
require "ruboty/twitter_stream_checker/version"

module Ruboty
  module TwitterStreamChecker
    CONSUMER_KEY = ENV["TWITTER_CONSUMER_KEY"]
    CONSUMER_SECRET = ENV["TWITTER_CONSUMER_SECRET"]
    ACCESS_TOKEN = ENV["TWITTER_ACCESS_TOKEN"]
    ACCESS_TOKEN_SECRET = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
  end
end
