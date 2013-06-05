#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "amqp"

$LOAD_PATH << "./lib"

require 'runner'
require 'server'

runner = Runner.new(ARGV)

require 'rack'
require 'sinatra/base'

class Resty < Sinatra::Base
  post("/foo.:fragment.:type") do
    puts "oh yeah"
    puts params.inspect
    status 200
  end

  not_found do
    binding.pry
  end
end

server = Server.new(connection: runner.connection_options, queues: Array(runner.options[:queue])) do
  resty = Resty.new

  run do |meta,payload|
    status, headers, response = resty.call({"REQUEST_METHOD" => "POST",
                "SCRIPT_NAME" => "",
                "PATH_INFO" => meta.type,
                "QUERY_STRING" => "",
                "SERVER_NAME" => "127.0.0.1",
                "SERVER_PORT" => 80,
                "rack.version" => Rack::VERSION,
                "rack.url_scheme" => "http",
                "rack.input" => StringIO.new(payload),
                "rack.errors" => StringIO.new,
                "rack.multithread" => false,
                "rack.multiprocess" => false,
                "rack.run_once" => false})

    if status == 200
      meta.ack
    end
  end
end

server.run

