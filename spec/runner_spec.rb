require 'spec_helper'
require 'runner'

describe Runner do
  def argsv(command,arguments={})
    arguments.inject([command]) do |m, (key,value)|
      m << "--#{key}"
      m << value
    end
  end

  it "should parse options" do
    runner = described_class.new(argsv("start",{host: "127.0.0.1", queue: "example.queue"}))

    expect(runner.options[:host]).to eql("127.0.0.1")
    expect(runner.options[:queue]).to eql("example.queue")
  end

  it "should parse specified command" do
    runner = described_class.new(argsv("start"))

    expect(runner.command).to eql("start")
  end

  it "should abort on unknown command"
  it "should exiit on empty command"
  it "should require file"
  it "should remember requires"
  it "should remember debug options"
  it "should default debug, silent and trace to false"
end

describe Runner, "with config file" do
  it "should load options from file"
  it "should change directory after loading config"
end
