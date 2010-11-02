require 'logger'

module Thinner

  class Configuration

    attr_accessor :batch_length, :sleep_time, :server, :log_file, :no_kill

    def initialize
      # Number of urls to purge at one time. These purge request are fired in quick
      # succession so it's best to be conservative and not overload the Varnish server.
      @batch_length = 10
      # The amount of time to sleep between purges in seconds.
      @sleep_time   = 1
      # The server address and management port. See:
      #   http://www.varnish-cache.org/trac/wiki/ManagementPort
      # for details.
      @server       = "127.0.0.1:6082"
      # By default, every time you start a Thinner.purge! it spins off a new instance
      # of a Thinner::Client and terminates any that are running. If you want to
      # have overlapping instances set this to true. It's not recommended to have
      # multiple Thinner::Client's running at the same time.
      @no_kill      = false
      # The log file (either a string or file object) to log the current batch to.
      # Defaults to STDOUT
      @log_file     = STDOUT
    end

    def logger
      if !log_file.respond_to?(:write)
        STDOUT.reopen(File.open(@log_file, (File::WRONLY | File::APPEND | File::CREAT)))
      end
      @logger = Logger.new(STDOUT)
    end

  end

end