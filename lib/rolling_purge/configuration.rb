module RollingPurge

  class Configuration

    attr_accessor :batch_length, :sleep_time, :server, :log_file

    def initialize
      @batch_length = 10
      @sleep_time   = 1
      @server       = "127.0.0.1:6082"
      @log_file     = STDOUT
    end

    def logger
      @logger = @log_file == STDOUT ? @log_file : File.open(@log_file)
    end
  end

end