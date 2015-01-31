require "twitter"
require 'pp'
module Ruboty
  module TwitterStreamChecker
    class Job
      include Mem
      attr_reader :attributes, :thread

      def initialize(attributes)
        @client = Twitter::Streaming::Client.new do |config|
          config.consumer_key = CONSUMER_KEY
          config.consumer_secret = CONSUMER_SECRET
          config.access_token = ACCESS_TOKEN
          config.access_token_secret = ACCESS_TOKEN_SECRET
        end

        @attributes = attributes.stringify_keys
      end

      def start(robot)
        @thread = Thread.new do
          @client.filter(track: check_word) do |tweet|
            if accept?(tweet)
              Message.new(
                attributes.symbolize_keys.except(:body, :check_word).merge(robot: robot)
              ).reply(*tweet_body(tweet))
            end
          end
        end
        self
      end

      def stop
        thread.kill
      end

      def accept?(tweet)
        !((except_retweet? && tweet.retweet?) || (except_reply? && tweet.reply?) || (ng_regexp && tweet.text.match(ng_regexp)))
      end

      def except_reply?
        ENV["TWITTER_ENABLE_EXCEPT_REPLY"] == 'true'
      end

      def except_retweet?
        ENV["TWITTER_ENABLE_EXCEPT_RETWEET"] == 'true'
      end

      def ng_regexp
        return nil if ENV["TWITTER_NG_REGEXP"].nil?
        Regexp.new(ENV["TWITTER_NG_REGEXP"])
      end
      memoize :ng_regexp

      def tweet_body(tweet)
        ["#{tweet.text.gsub(/\n/,' ')} #{tweet.url}", message_option]
      end

      def message_option
        return {} if ENV["TWITTER_MESSAGE_OPTION"].nil?
        return eval(ENV["TWITTER_MESSAGE_OPTION"])
      end
      memoize :message_option

      def to_hash
        attributes
      end

      def description
        "Tweet checking #{check_word}"
      end

      def id
        attributes["id"]
      end

      def check_word
        attributes["check_word"]
      end

      def from
        attributes["from"]
      end

      def to
        attributes["to"]
      end
    end
  end
end
