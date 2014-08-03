module Ruboty
  module TwitterStreamChecker
    class Job
      attr_reader :attributes, :thread

      def initialize(attributes)
        @attributes = attributes.stringify_keys
      end

      def start(robot)
        @thread = Thread.new do
          TweetStream::Client.new.track(check_word) do |tweet|
            if accept?(tweet)
              Message.new(
                attributes.symbolize_keys.except(:body, :check_word).merge(robot: robot)
              ).reply("[#{tweet.user.name}]:#{tweet.text.gsub(/\n/,' ')} #{tweet.url}")
            end
          end
        end
        self
      end

      def accept?(tweet)
        return false if (except_retweet? && tweet.retweet?) || (except_reply? && tweet.reply?)
        true
      end

      def except_reply?
        ENV["TWITTER_EXCEPT_REPLY"] == 'true'
      end

      def except_retweet?
        ENV["TWITTER_EXCEPT_RETWEET"] == 'true'
      end

      def to_hash
        attributes
      end

      def stop
        thread.kill
      end

      def description
        "checking #{check_word.join(',')}"
      end

      def id
        attributes["id"]
      end

      def check_word
        attributes["check_word"].split(',').map(&:strip)
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
