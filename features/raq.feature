Feature: Raq provides a friendly and familiar way of consuming messages off a durable queue.
  In order to be happy with consuming amqp messages
  A user wants to deal with the smallest amount of connection information in code as possible

  @amqp
  Scenario: Happily receiving a message on a single queue
    Given I produce a message "Hello" on the queue "single.queue"
    And a consumer with:
    """
    runner = Raq::Runner.new(ARGV)
    server = Raq::Server.new(
      connection: runner.connection_options,
      queues: runner.options[:queue]) do

      run do |meta, payload|
        puts "Got #{payload}"
        meta.ack
        exit
      end
    end

    server.run
    """
    When I run the consumer on the queue "single.queue"
    Then the output should contain "Got Hello"

  @amqp
  Scenario: An agent crashes, another receives the message
    Given I produce a unique message on the queue "single.queue"
    And a consumer "crasher" with:
    """
    runner = Raq::Runner.new(ARGV)
    server = Raq::Server.new(
      connection: runner.connection_options,
      queues: runner.options[:queue]) do

      run do |meta, payload|
        raise "Ahh! I'm going to die alone!"
      end
    end

    server.run
    """
    And a consumer with:
    """
    runner = Raq::Runner.new(ARGV)
    server = Raq::Server.new(
      connection: runner.connection_options,
      queues: runner.options[:queue]) do

      run do |meta, payload|
        puts "Got #{payload}"
        meta.ack
        exit
      end
    end

    server.run
    """
    And I run the consumer "crasher" on the queue "single.queue", failing
    When I run the consumer on the queue "single.queue"
    Then the output should contain the unique message
