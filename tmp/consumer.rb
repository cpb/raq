#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "amqp"

$LOAD_PATH << "./lib"

require 'runner'
require 'server'

runner = Runner.new(ARGV)

server = Server.new(connection: runner.connection_options, queues: Array(runner.options[:queue])) do
  run do |meta,payload|
    puts "Received a message: #{meta} #{payload}"

    if payload == "ack me"
      meta.ack
    end
  end
end

server.run

