require 'optparse'

class Runner
  attr_reader :options
  attr_reader :command

  def initialize(argv)
    @argv = argv

    @options = {}

    parse!
  end

  def parser
    @parser ||= OptionParser.new do |opts|
      opts.on("-H", "--host HOST", "AMQP HOST address (default: #{@options[:host]}") { |host| @options[:host] = host }
    end
  end

  def parse!
    parser.parse! @argv
    @command = @argv.shift
  end
end
