class Server
  class Builder

    def initialize(&block)
      @middleware = []
      @app = proc {}
      instance_eval(&block)
    end

    def use(middleware)
      @middleware << middleware
    end

    def run(app=nil,&block_as_app)
      @app = app if app
      @app = block_as_app if block_as_app
    end

    def to_app
      @middleware.inject(@app) do |app,middleware|
        middleware.new(app)
      end
    end
  end
end
