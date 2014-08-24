module Ruboty
  module TwitterStreamChecker
    class Job
      include Mem
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
              ).reply("#{tweet.text.gsub(/\n/,' ')} #{tweet.url}")
            end
          end
        end
        self
      end

      def accept?(tweet)
        !((except_retweet? && tweet.retweet?) || (except_reply? && tweet.reply?) || tweet.match(ng_regexp))
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
