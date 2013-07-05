Raq [![Build Status](https://travis-ci.org/cpb/raq.png?branch=master)](https://travis-ci.org/cpb/raq) [![Dependency Status](https://gemnasium.com/cpb/raq.png)](https://gemnasium.com/cpb/raq) [![Code Climate](https://codeclimate.com/repos/51d5c98289af7e2eda089f9a/badges/f4cb8a49dee9210b9775/gpa.png)](https://codeclimate.com/repos/51d5c98289af7e2eda089f9a/feed)
===

Raq makes it easy to create durable message queue consumers. It tries to learn from [Thin](https://github.com/macournoyer/thin) and [Rack](https://github.com/rack/rack) in order to provide a reasonably familiar way of creating and running AMQP consumers.

Raq expresses the opinion that, like database configuration, queue configuration should be configured by the environment. Raq offers the ability to specify message broker connection information and queue names as command line flags, or in an separate configuration file.

Installation
------------

Add this to your Gemfile:

```ruby
gem 'raq'
```

Then install it by running Bundler:

```bash
$ bundle
```

Usage
-----

Raq provides a Rack-like api for creating consumers and message middleware by implementing ```run``` and ```use```.

However, unlike Rack, Raq does not infer anything about the payload. It exposes the protocol level meta information, and the unmodified payload body directly as arguments to your consumers. Though, you can quickly chain together middleware to satisfy your application.

Consider this example.rb:

```ruby
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
```

When run like so:
```bash
$ ruby example.rb --queue a.queue.with.messages
```

It will print the payload to stdout a couple times, acknowledge the message, and exit.

== Contributing to raq

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2013 Caleb Buxton. See LICENSE.txt for further details.

