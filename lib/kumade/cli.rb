require 'optparse'
require 'stringio'

module Kumade
  class CLI
    class << self
      attr_reader :environment
    end

    def self.run(args = ARGV, out = StringIO.new)
      @out         = out
      @options     = parse_arguments!(args)
      @environment = args.shift || 'staging'

      swapping_stdout_for(@out) do
        deploy
      end
    end

    def self.deploy
      if pretending?
        puts "==> In Pretend Mode"
      end
      puts "==> Deploying to: #{environment}"
      Deployer.new(environment, pretending?).deploy
      puts "==> Deployed to: #{environment}"
    end

    def self.parse_arguments!(args)
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: kumade <environment> [options]"

        opts.on("-p", "--pretend", "Pretend mode: print what kumade would do") do |p|
          options[:pretend] = p
        end

        opts.on_tail('-v', '--version', 'Show version') do
          puts "kumade #{Kumade::VERSION}"
          exit
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end.parse!(args)

      options
    end

    def self.swapping_stdout_for(io)
      if pretending?
        yield
      else
        begin
          real_stdout = $stdout
          $stdout     = io
          yield
        rescue Kumade::DeploymentError
          io.rewind
          real_stdout.print(io.read)
        ensure
          $stdout = real_stdout
        end
      end
    end

    def self.pretending?
      @options[:pretend]
    end
  end
end