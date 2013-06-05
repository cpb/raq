require 'optparse'

class Runner
  attr_reader :options
  attr_reader :command
  attr_reader :connection_options

  def initialize(argv)
    @argv = argv

    @options = {}

    parse!
  end

  def parser
    @parser ||= OptionParser.new do |opts|
      opts.on("-H", "--host HOST", "AMQP HOST address (default: #{@options[:host]}") { |host| @options[:host] = host }
      opts.on("-p", "--port PORT", "AMQP PORT") { |port| @options[:port] = port.to_i }
      opts.on("-q", "--queue QUEUE","AMQP Queue to use") { |queue| @options[:queue] = queue }
      opts.on("-u", "--user USER","AMQP User to connect as") { |user| @options[:user] = user }
      # ... and on
    end
  end

  def parse!
    parser.parse! @argv
    @command = @argv.shift
    @connection_options = @options.reject {|k,v| k == :queue}
  end
end
