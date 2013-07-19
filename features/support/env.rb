require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

require 'rspec/expectations'
require 'aruba/cucumber'

require 'simplecov'
SimpleCov.command_name("features")

require 'raq'

module PryHelper
  def pry(byending)
    begin
      byending.pry
    rescue NoMethodError => e
      require 'pry'
      byending.pry
    end
  end
end

module CoverageHelper
  def simplecov_for(path)
    %{
    require 'simplecov'
    SimpleCov.command_name(#{path.inspect})
    SimpleCov.start
    SimpleCov.root(#{File.join(File.dirname(__FILE__),'..','..').inspect})
    } unless ENV.has_key?('ARUBA_REPORT_DIR')
  end
end

module RaqUnderTestHelper
  def load_path
    File.dirname(__FILE__) + '/../../lib'
  end

  def full_current_dir
    File.expand_path(File.dirname(__FILE__) + '/../../' + current_dir)
  end
end

module DependentServiceHelper
  def start_amqp
    unless rabbitmq_running?
      system("rabbitmq-server &", out: "/dev/null", err: "/dev/null")
      unless system("rabbitmqctl wait /usr/local/var/lib/rabbitmq/mnesia/rabbit@localhost.pid", out: "/dev/null", err: "/dev/null")
        raise "Unable to start rabbitmq"
      else
        true
      end
    end
  end

  def rabbitmq_running?
    system("rabbitmqctl status", err: :out, out: STDOUT)
  end

  def stop_amqp
    if rabbitmq_running?
      unless system("rabbitmqctl stop", out: "/dev/null", err: "/dev/null")
        raise "Unable to stop rabbitmq"
      else
        true
      end
    end
  end
end

module AgentSessionHelper

  def new_queue(name=nil)
    with_queues do
      queue_name = name || (Digest::MD5.new << Time.now.to_s << rand(1000).to_s)
      if @queues.include?(queue_name)
        queue_name
      else
        @queues << queue_name
        @queues.last
      end
    end
  end

  def last_queue
    with_queues do
      @queues.last
    end
  end

  def with_queues
    @queues ||= Array.new
    yield
  end

  def current_message(new_message=nil)
    with_messages do
      @messages << new_message if new_message
      @messages.last
    end
  end

  def last_message
    with_messages do
      @messages.last
    end
  end

  def with_messages
    @messages ||= Array.new
    yield
  end

  def new_consumer_path(fragment="consumer")
    with_consumers do
      @consumers << "#{fragment}#{@consumers.length}.rb"
      @consumers.last
    end
  end

  def last_consumer_path(fragment=nil)
    with_consumers do
      if fragment
        @consumers.reverse.find {|c| c.include?(fragment)}
      else
        @consumers.last
      end
    end
  end

  def with_consumers
    @consumers ||= Array.new
    yield
  end
end

World(PryHelper,RaqUnderTestHelper,DependentServiceHelper,AgentSessionHelper,CoverageHelper)
