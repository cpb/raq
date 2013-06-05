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
  queue    = channel.queue(runner.options[:queue], :auto_delete => true)
  exchange = channel.direct("")

  queue.subscribe do |payload|
    puts "Received a message: #{payload}. Disconnecting..."
    connection.close { EventMachine.stop }
  end
end
