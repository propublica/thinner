require 'logger'

module Thinner
  # Thinner::Configuration holds the various settings for Thinner
  class Configuration

    attr_accessor :batch_length, :sleep_time, :server, :log_file, :no_kill

    # Create a Thinner::Configutation instance with sane defaults.
    def initialize
      # Number of urls to purge at one time. These purge requests are fired in quick
      # succession, so it's best to be conservative and not overload the Varnish
      # server.
      @batch_length = 10
      # The amount of time to sleep between purges in seconds.
      @sleep_time   = 1
      # The server address and management port. See:
      #   http://www.varnish-cache.org/trac/wiki/ManagementPort
      # for details.
      @server       = "127.0.0.1:6082"
      # By default, every time you call Thinner.purge! thinner spins off a new
      # instance of Thinner::Client and terminates any old instances that are
      # running. If you want to have overlapping instances set this to true.
      # It's not recommended to have multiple Thinner::Client's running at the
      # same time.
      @no_kill      = false
      # The log file (either a string or file object) to log the current batch to.
      # Defaults to STDOUT
      @log_file     = STDOUT
    end

  end

end