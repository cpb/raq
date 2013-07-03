require 'raq/server/builder'
require 'eventmachine'
require 'amqp'

module Raq
  class Server
    CONNECTION_DEFAULTS = {host: "127.0.0.1"}

    attr_reader :connection_options, :queue_names, :connection, :app

    def initialize(options={}, app=nil, &block)
      @queue_names = options.fetch(:queues) { raise ArgumentError, "You must provide a list of at least 1 queue to subscribe to." }
      @connection_options = options.fetch(:connection,CONNECTION_DEFAULTS)
      @app = app
      @app = Server::Builder.new(&block).to_app if block
    end

    def run
      starter = proc do
        connect
      end

      if EventMachine.reactor_running?
        starter.call
      else
        EventMachine.run(&starter)
      end
    end

    def connect
      @connection = AMQP.connect(self.connection_options)
      @channel    = AMQP::Channel.new(@connection)
      #@channel.prefetch(1)
      @queues     = Array(self.queue_names).collect do |queue_name|
        queue = @channel.queue(queue_name, durable: true, auto_delete: false)
        queue.subscribe(ack: true, &method(:handle_message))
      end
    end

    def handle_message(meta, payload)
      @app.call(meta,payload,self.connection)
    end
  end
end
