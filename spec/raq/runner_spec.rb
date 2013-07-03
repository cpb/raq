require 'spec_helper'
require 'raq/runner'

describe Raq::Runner do
  def argsv(command,arguments={})
    arguments.inject([command]) do |m, (key,value)|
      m << "--#{key}"
      m << value
    end
  end

  context "options" do
    it "should parse host" do
      runner = described_class.new(%w(start --host 127.0.0.1))

      expect(runner.options[:host]).to eql("127.0.0.1")

      runner = described_class.new(%w(start -H host))

      expect(runner.options[:host]).to eql("host")
    end

    it "should parse port" do
      runner = described_class.new(%w(start --port 8080))

      expect(runner.options[:port]).to eql(8080)

      runner = described_class.new(%w(start -p 888))

      expect(runner.options[:port]).to eql(888)
    end

    it "should parse user" do
      runner = described_class.new(%w(start --user guest))

      expect(runner.options[:user]).to eql("guest")

      runner = described_class.new(%w(start -u gus))

      expect(runner.options[:user]).to eql("gus")
    end

    # pass=>"[filtered]"
    # auth_mechanism=>"PLAIN"
    # vhost=>"/"
    # timeout=>nil
    # logging=>false
    # ssl=>false
    # broker=>nil
    # frame_max=>131072
    # heartbeat=>0}"
  end

  it "should parse specified command" do
    runner = described_class.new(argsv("start"))

    expect(runner.command).to eql("start")
  end

  it "should parse AMQP Connection options" do
    runner = described_class.new(%w("start --host host.name --queue is.not.a.connection.option"))

    expect(runner.connection_options).to_not include(:queue)
  end

  it "should abort on unknown command"
  it "should exiit on empty command"

  it "should require file" do
    expect do
      Raq::Runner.new(%w(start -r unexisting))
    end.to raise_error(LoadError)
  end

  it "should remember requires"
  it "should remember debug options"
  it "should default debug, silent and trace to false"
end

describe Raq::Runner, "with config file" do
  it "should load options from file"
  it "should change directory after loading config"
end
