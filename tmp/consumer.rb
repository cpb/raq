#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "amqp"

$LOAD_PATH << "./lib"

require 'runner'
require 'server'

runner = Runner.new(ARGV)

module Raq
  class Pryable < Struct.new(:app)
    def call(meta, payload)
      binding.pry if payload == "pry"
      self.app.call(meta, payload)
    end
  end

  class QuickAck < Struct.new(:app)
    def call(meta, payload)
      if payload == "ack me"
        meta.ack
        puts "Pre-acked #{payload}"
      else
        self.app.call(meta, payload)
      end
    end
  end

  class FailureNack < Struct.new(:app)
    def call(meta, payload)
      begin
        self.app.call(meta, payload)
        meta.ack
      rescue => e
        puts "Got #{e}, not acking"
      end
    end
  end
end

server = Server.new(connection: runner.connection_options, queues: Array(runner.options[:queue])) do
  use Raq::Pryable
  use Raq::QuickAck
  use Raq::FailureNack

  run do |meta,payload|
    puts "Received a message: #{meta} #{payload}"
    raise "flaky ruby, you can't even scale" if rand(2) == 0
  end
end

server.run

