require 'optparse'
require "#{File.dirname __FILE__}/../thinner.rb"

module Thinner

  class CommandLine

    def initialize
      @urls = ARGV || []
      options!
      run!
    end

    def run!
      Thinner.configure do |config|
        @options.each_pair do |key, value|
          config.send("#{key}=".to_sym, value)
        end
      end
      Thinner.purge! @urls
    end

    private

    def options!
      @options = {}
      @option_parser = OptionParser.new do |opts|
        opts.on("-b", "--batch_length BATCH", "number of urls to purge at once") do |b|
          @options[:batch_length] = b.to_i
        end
        opts.on("-t", "--sleep_time SLEEP", "time to wait in between batches") do |t|
          @options[:sleep_time] = t.to_i
        end
        opts.on("-e", "--stdin", "use stdin for urls") do
          ARGF.each_line do |url|
            @urls << url
          end
        end
        opts.on("-s", "--server SERVER", "Varnish url, e.g. 127.0.0.1:6082") do |s|
          @options[:server] = s
        end
        opts.on("-o", "--log_file LOG_PATH", "Log file to output to defaults to standard out") do |o|
          @options[:log_file] = o
        end
        opts.on("-n", "--no-kill", "Don't kill the running purgers if they exist") do |n|
          @options[:no_kill] = n
        end
      end

      begin
        @option_parser.parse!(ARGV)
      rescue OptionParser::InvalidOption => e
        puts e.message
        exit(1)
      end
    end

  end

end
