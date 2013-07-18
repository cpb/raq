QUEUE = Transform /^(?:the queue(?: "(.*?)")?|(a new queue))$/ do |named_queue,make_a_new_queue|
  if named_queue
    new_queue(named_queue)
  elsif make_a_new_queue
    new_queue
  else
    last_queue
  end
end

SOME_MESSAGE = Transform /^(?:a message "(.*?)"|(a unique message))$/ do |specific_message,unique_message|
  if unique_message
    current_message(Digest::MD5.new << Time.now.to_s << rand(10000).to_s)
  else
    current_message(specific_message)
  end
end

EXPECT_SOME_MESSAGE = Transform /^the unique message$/ do |string|
  last_message
end

A_CONSUMER = Transform /^a consumer(?: "(.*?)")?$/ do |possible_name|
  if possible_name
    new_consumer_path(possible_name)
  else
    new_consumer_path
  end
end

THE_CONSUMER = Transform /^the consumer(?: "(.*?)")?$/ do |possible_name|
  if possible_name
    last_consumer_path(possible_name)
  else
    last_consumer_path
  end
end

Given(/^a raq agent file named "(.*?)" with:$/) do |name, content|
  step %{a file named "#{name}" with:},%{
#{simplecov_for(name)}
require 'raq'

#{content}
  }
end

Given(/^I produce (#{SOME_MESSAGE}) on (#{QUEUE})/) do |message, queue|
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
  step %{a raq agent file named "#{consumer_path}" with:},consumer_implementation
end

When(/^I run the raq agent "(.*?)"(, failing)?(, again)?$/) do |agent_run_string, failing, again|
  running = lambda do
    steps %{
      When I #{'successfully ' unless failing || again}run `ruby -I#{full_current_dir} -I#{load_path} #{agent_run_string}`
    }

    if failing
      steps %{
        Then the exit status should not be 0
      }
    end
  end

  if again
    expect(&running).to raise_error(ChildProcess::TimeoutError)
  else
    running.call
  end
end

When(/^I run (#{THE_CONSUMER}) with "(.*?)"$/) do |consumer, arguments|
  steps %{
    When I run the raq agent "#{consumer} #{arguments}"
  }
end

When(/^I run (#{THE_CONSUMER}) on (#{QUEUE})(, failing)?(, again)?$/) do |consumer, queue, failing, again|
  steps %{
    When I run the raq agent "#{consumer} --queue #{queue}"#{failing}#{again}
  }
end

Then(/^the output should contain (#{EXPECT_SOME_MESSAGE})$/) do |message|
  steps %{
    Then the output should contain "#{message}"
  }
end

Then(/^it should never return$/) do
  expect do
    Timeout::timeout(exit_timeout) do
      loop do
        assert_not_exit_status(0)
        assert_not_exit_status(1)
        sleep(0.1)
      end
    end
  end.to raise_error(Timeout::Error)
  terminate_processes!
end
