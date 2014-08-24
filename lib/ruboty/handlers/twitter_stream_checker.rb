module Ruboty
  module Handlers
    class TwitterStreamChecker < Base
      attr_reader :running_job

      NAMESPACE = "twitter_stream_checker"

      on(/start tweet_check (?<check_word>.+)/, name: "start", description: "start new tweet_check")
      on(/stop tweet_check/, name: "stop", description: "Stop a tweet_check")
      on(/show tweet_check\z/, name: "show", description: "Show tweet_check")

      env :TWITTER_CONSUMER_KEY, "Twitter consumer key (a.k.a. API key)"
      env :TWITTER_CONSUMER_SECRET, "Twitter consumer secret (a.k.a. API secret)"
      env :TWITTER_ACCESS_TOKEN, "Twitter access token"
      env :TWITTER_ACCESS_TOKEN_SECRET, "Twitter access token secret"
      env :TWITTER_ENABLE_EXCEPT_RETWEET, "Twitter except retweet: true or false", optional: true
      env :TWITTER_ENABLE_EXCEPT_REPLY, "Twitter except reply: true or false", optional: true
      env :TWITTER_NG_REGEXP, "Twitter except regexp, like hoge,huga", optional: true
      env :TWITTER_MESSAGE_OPTION, "Twitter message option", optional: true

      def initialize(*args)
        super

        TweetStream.configure do |config|
          config.consumer_key       = ENV["TWITTER_CONSUMER_KEY"]
          config.consumer_secret    = ENV["TWITTER_CONSUMER_SECRET"]
          config.oauth_token        = ENV["TWITTER_ACCESS_TOKEN"]
          config.oauth_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
          config.auth_method        = :oauth
        end

        check_start
      end

      def start(message)
        create(message)
        message.reply("Tweet check is started")
      end

      def stop(message)
        if registered?
          unregistered
          message.reply("Tweet check is stopped")
        else
          message.reply("Checking tweet is does not exist")
        end
      end

      def show(message)
        message.reply(summary, code: true)
      end

      def check_start
        if registered?
          job = Ruboty::TwitterStreamChecker::Job.new(registered)
          running_job = job.start(robot)
        end
      end

      def create(message)
        unregistered if registered?

        job = Ruboty::TwitterStreamChecker::Job.new(
          message.original.except(:robot).merge(
            check_word: message[:check_word],
          )
        )
        register(job)
        running_job = job.start(robot)
        job
      end

      def summary
        if registered?
          job_descriptions
        else
          empty_message
        end
      end

      def empty_message
        "Not checking now"
      end

      def job_descriptions
        Ruboty::TwitterStreamChecker::Job.new(registered).description
      end

      def register(job)
        robot.brain.data[NAMESPACE] = job.attributes
      end

      def registered?
        !robot.brain.data[NAMESPACE].nil?
      end

      def registered
        robot.brain.data[NAMESPACE]
      end

      def unregistered
        robot.brain.data[NAMESPACE] = nil
        if running_job
          running_job.stop
          running_job = nil
        end
      end
    end
  end
end
