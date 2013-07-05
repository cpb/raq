Feature: The README instructions and examples

  @disable-bundler
  Scenario: Installation
    Given a file named "Gemfile" with:
    """
    gem 'raq', path: '../../'
    """
    When I run `bundle install`
    Then the output should match /Using raq \(\d+\.\d+\.\d+\) from source at ../

  @amqp
  Scenario: Usage
    Given a file named "example.rb" with:
    """
    $: << '../../lib'
    require 'raq'

    class Echo < Struct.new(:app)
      def call(meta, payload)
        puts "Echo: #{payload}"
        app.call(meta,payload)
      end
    end

    runner = Raq::Runner.new(ARGV)
    server = Raq::Server.new(
      connection: runner.connection_options,
      queues: runner.options[:queue]) do

      use Echo

      run do |meta, payload|
        puts "Acknowledging #{payload}"
        meta.ack

        # Not for long lived processes...
        server.connection.close { EM.stop }
      end
    end

    server.run
    """
    And I produce a message "Usage\ Example" on the queue "readme.usage.examples"
    When I run `ruby example.rb --queue readme.usage.examples`
    Then the output should contain "Echo: Usage Example"
    And the output should contain "Acknowledging Usage Example"
