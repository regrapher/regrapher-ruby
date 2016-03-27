require 'json'
require 'securerandom'

module Regrapher
  # Examples:
  #   client.increment 'page.views'
  #   client.gauge 'users.online', 100.43
  #   client.event 'clients.sign_ups', :title=>'Premium Package Sold', :text=>'Hurray !'
  class Client
    # A namespace to prepend to all statsd calls. Defaults to no namespace.
    attr_reader :namespace

    # Global tags to be added to every statsd call. Defaults to no tags.
    attr_reader :tags

    # Output stream used to log metrics and event data. Defaults to STDOUT.
    attr_reader :output_stream

    # @param [Hash] opts
    # @option opts [String] :namespace set a namespace to be prepended to every metric name
    # @option opts [Array<String>] :tags tags to be added to every metric
    # @option opts :output_stream an object with a puts method that takes accepts a string parameter
    def initialize(opts = {})
      @namespace     = opts[:namespace]
      @tags          = opts.fetch(:tags, []).uniq
      @output_stream = opts.fetch(:output_stream, STDOUT)
    end

    # Sends an increment (count = 1) for the given metric.
    #
    # @param [String] name metric name
    # @param [Hash] opts the options to create the metric with
    # @option opts [Numeric] :sample_rate sample rate, 1 for always
    # @option opts [Array<String>] :tags An array of tags
    # @see #count
    def increment(name, opts={})
      count(name, 1, opts)
    end

    # Sends a decrement (count = -1) for the given metric.
    #
    # @param [String] name metric name
    # @param [Hash] opts the options to create the metric with
    # @option opts [Numeric] :sample_rate sample rate, 1 for always
    # @option opts [Array<String>] :tags An array of tags
    # @see #count
    def decrement(name, opts={})
      count(name, -1, opts)
    end

    # Sends an arbitrary count for the given metric.
    #
    # @param [String] name metric name
    # @param [Integer] count count
    # @param [Hash] opts the options to create the metric with
    # @option opts [Numeric] :sample_rate sample rate, 1 for always
    # @option opts [Array<String>] :tags An array of tags
    def count(name, count, opts={})
      send_metric('c', name, count, opts)
    end

    # Sends an arbitrary gauge value for the given metric.
    #
    # This is useful for recording things like available disk space,
    # memory usage, and the like, which have different semantics than
    # counters.
    #
    # @param [String] name metric name.
    # @param [Numeric] value gauge value.
    # @param [Hash] opts the options to create the metric with
    # @option opts [Numeric] :sample_rate sample rate, 1 for always
    # @option opts [Array<String>] :tags An array of tags
    # @example Report the current user count:
    #   client.gauge('user.count', User.count)
    def gauge(name, value, opts={})
      send_metric('g', name, value, opts)
    end

    # Sends events to the stream of events.
    #
    # @param [String] name metric name.
    # @param [Hash] value the event value. Should contain a title and text. Could contain any other custom data.
    # @option value[String] :title Event title.
    # @option value [String, nil] :text Event text. Supports +\n+.
    # @param [Hash] opts the additional data about the event
    # @option opts [Array<String>] :tags tags to be added to every metric
    # @example Report an event:
    #   client.event('clients.sign_ups', {:title=>'New VIP Client', text=>'Hurray !',
    #     :data=>{:name=>'Doe',:photo=>'http://example.com/12.jpg'}}, :tags=>['region:US_CAL','payment:paypal'])
    def event(name, value, opts={})
      send_metric('e', name, value, opts)
    end

    private

    def send_metric(type, name, value, opts={})
      sample_rate = opts.fetch(:sample_rate, 1)
      return unless sample_rate >= 1 || rand < sample_rate
      name = "#{namespace}.#{name}" if namespace
      obj  = opts.merge(:type  => type,
                        :name  => name,
                        :value => value,
                        :ts    => Time.now.to_i,
                        :id    => SecureRandom.uuid)
      tags = (opts[:tags] || []) | self.tags
      obj.merge!(:tags => tags) unless tags.empty?
      obj_json = JSON::generate(obj)
      output_stream.puts "[regrapher][#{obj_json.length}]#{obj_json}"
    end
  end
end