A_CONSUMER = Transform /^a consumer$/ do |string|
  new_consumer_path
end

THE_CONSUMER = Transform /^the consumer$/ do |string|
  last_consumer_path
end

Given(/^a raq agent file named "(.*?)" with:$/) do |name, content|
  steps %{
    Given a file named "#{name}" with:
    """
    #{simplecov_for(name)}
    require 'raq'

    #{content}
    """
  }
end

Given(/^I produce a message "(.*?)" on the queue "(.*?)"$/) do |message, queue|
  steps %{
    Given a raq agent file named "producer.rb" with:
    """
    runner = Raq::Runner.new(ARGV)

    EventMachine.run do
      connection = AMQP.connect(runner.connection_options)

      puts "Connected to AMQP broker. Running \#{AMQP::VERSION} version of the gem..."

      channel  = AMQP::Channel.new(connection)
      queue    = channel.queue(runner.options[:queue], durable: true, auto_delete: false)
      exchange = channel.direct("")

      puts "publshing \#{runner.command} to \#{queue.name}"
      exchange.publish runner.command, routing_key: queue.name, persistent: true, type: runner.options[:type]

      EventMachine.add_timer(1) { connection.close { EventMachine.stop } }
    end
    """
    When I run the raq agent "producer.rb #{message} --queue #{queue}"
  }
end

Given(/^(#{A_CONSUMER}) with:$/) do |consumer_path, consumer_implementation|
  steps %{
    Given a raq agent file named "#{consumer_path}" with:
    """
    #{consumer_implementation}
    """
  }
end

When(/^I run the raq agent "(.*?)"$/) do |agent_run_string|
  begin
    steps %{
      When I successfully run `ruby -I#{load_path} #{agent_run_string}`
    }
  rescue => e
    pry(binding)
  end
end

When(/^I run (#{THE_CONSUMER}) on the queue "(.*?)"$/) do |consumer, queue|
  steps %{
    When I run the raq agent "#{consumer} --queue #{queue}"
  }
end
