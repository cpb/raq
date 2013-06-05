#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "amqp"

require './lib/runner'

runner = Runner.new(ARGV)

EventMachine.run do
  connection = AMQP.connect(runner.connection_options)

  puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

  channel  = AMQP::Channel.new(connection)
  queue    = channel.queue(runner.options[:queue], durable: true, auto_delete: false)
  exchange = channel.direct("")

  puts "publshing #{runner.command} to #{queue.name}"
  exchange.publish runner.command, routing_key: queue.name, persistent: true, type: runner.options[:type]

  EventMachine.add_timer(1) { connection.close { EventMachine.stop } }
end
