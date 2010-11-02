require 'optparse'
require File.expand_path("#{File.dirname __FILE__}/../thinner.rb")

module Thinner

  class CommandLine

    # Usage and summary
    BANNER = <<-EOF
Thinner purges varnish caches as slowly as you need it to.

Documentation: http://propublica.github.com/thinner/

Usage: thinner OPTIONS URL

Options:
EOF
    # Create a Thinner::CommandLine, parse any associated options, grab a list
    # of urls and start the process
    def initialize
      @urls = []
      options!
      @urls ||= ARGV
      run!
    end

    # Build a Thinner::Configuration instance from the passed in options and go
    # to the races.
    def run!
      Thinner.configure do |config|
        @options.each_pair do |key, value|
          config.send("#{key}=".to_sym, value)
        end
      end
      Thinner.purge! @urls
    end

    private

    # Parse the command line options using OptionParser.
    def options!
      @options = {}
      @option_parser = OptionParser.new(BANNER) do |opts|
        opts.on("-b", "--batch_length BATCH", "Number of urls to purge at once") do |b|
          @options[:batch_length] = b.to_i
        end
        opts.on("-t", "--sleep_time SLEEP", "Time to wait in between batches") do |t|
          @options[:sleep_time] = t.to_i
        end
        opts.on("-e", "--stdin", "Use stdin for urls") do
          ARGF.each_line do |url|
            @urls << url.chomp
          end
        end
        opts.on("-s", "--server SERVER", "Varnish url, e.g. 127.0.0.1:6082") do |s|
          @options[:server] = s
        end
        opts.on("-o", "--log_file LOG_PATH", "Log file to output to (default: Standard Out") do |o|
          @options[:log_file] = o
        end
        opts.on("-n", "--no-kill", "Don't kill the running purgers if they exist") do |n|
          @options[:no_kill] = n
        end
        opts.on_tail("-h", "--help", "Display this help message") do
          puts opts.help
          exit
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
