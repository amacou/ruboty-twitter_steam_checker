require 'digest/md5'

module Ruboty
  module Handlers
    class TwitterStreamChecker < Base
      NAMESPACE = "twitter_stream_checker"

      on(/start tweet_check (?<check_word>.+)/, name: "start", description: "start new tweet_check")
      on(/stop tweet_check (?<check_word>.+)/, name: "stop", description: "stop a tweet_check")
      on(/list tweet_check\z/, name: "list", description: "list tweet_check")


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
        compatible_brain
        check_start
      end

      def start(message)
        create(message)
        message.reply("Tweet check #{message[:check_word]} is started")
      end

      def stop(message)
        job_id = job_id_for_message(message)

        if registered?(job_id)
          unregistered(job_id)
          message.reply("Tweet check #{message[:check_word]} is stopped ")
        else
          message.reply("Checking tweet check #{message[:check_word]} is does not exist")
        end
      end

      def list(message)
        if job_descriptions.present?
          job_descriptions.each do |description|
            message.reply(description, code: true)
          end
        else
          message.reply(empty_message, code: true)
        end
      end

      def check_start
        registered.values.each do |value|
          job = Ruboty::TwitterStreamChecker::Job.new(value)
          job.start(robot)
        end
      end

      def create(message)
        job_id = job_id_for_message(message)

        return if registered?(job_id)

        job = Ruboty::TwitterStreamChecker::Job.new(
          message.original.except(:robot).merge(
          check_word: message[:check_word],
          id: job_id
          )
        )
        register(job)
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
        running_jobs.values.map(&:description)
      end

      def register(job)
        registered[job.id] = job.attributes
        running_jobs[job.id] = job.start(robot)
      end

      def registered?(job_id)
        registered[job_id].present?
      end

      def registered
        robot.brain.data[NAMESPACE] ||= {}
      end

      def unregistered(job_id)
        return nil unless registered?(job_id)

        registered.delete(job_id)

        if running_jobs[job_id]
          running_jobs[job_id].stop
          running_jobs.delete job_id
        end
      end

      def running_jobs
        @running_jobs ||= {}
      end

      def job_id_for_message(message)
        Digest::MD5.hexdigest(message[:check_word])
      end

      private

      def compatible_brain
        if registered.is_a(String)
          robot.brain.data[NAMESPACE] = {}
        end
      end
    end
  end
end
