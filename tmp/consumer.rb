#!/usr/bin/env ruby
# encoding: utf-8

$LOAD_PATH << "./lib"

require 'raq/runner'
require 'raq/server'

runner = Raq::Runner.new(ARGV)

module Raq
  class Pryable < Struct.new(:app)
    def call(meta, payload)
      if payload == "pry"
        binding.pry
      else
        self.app.call(meta,payload)
      end
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
        puts "acked #{payload}"
      rescue => e
        puts "Got #{e}, not acking"
      end
    end
  end
end

server = Raq::Server.new(connection: runner.connection_options, queues: Array(runner.options[:queue])) do
  use Raq::QuickAck
  use Raq::FailureNack
  use Raq::Pryable

  run do |meta,payload|
    puts "Received a message: #{meta} #{payload}"
    raise "flaky ruby, you can't even scale" if rand(5) == 0
  end
end

server.run

