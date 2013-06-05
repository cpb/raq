require 'spec_helper'
require 'server'

describe Server, 'app builder' do
  class ExampleMiddleware < Struct.new(:app)
    def call(meta,payload)
      self.app.call(meta,payload)
    end
  end

  it "should build app from constructor" do
    app = proc {}
    server = Server.new({queues: "queue.name"}, app)

    server.app.should == app
  end

  it "should build app from builder block" do
    server = Server.new queues: "queue.name" do
      run(proc { |meta,payload| :works })
    end

    server.app.call({}).should == :works
  end

  it "should use middlewares in builder block" do
    server = Server.new queues: "queue.name" do
      use ExampleMiddleware
      run(proc { |meta,payload| :works })
    end

    server.app.class.should == ExampleMiddleware
    server.app.call("meta","payload").should == :works
  end
end
