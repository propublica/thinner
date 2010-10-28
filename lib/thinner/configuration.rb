require 'logger'

module Thinner

  class Configuration

    attr_accessor :batch_length, :sleep_time, :server, :log_file, :kill

    def initialize
      @batch_length = 10
      @sleep_time   = 1
      @server       = "127.0.0.1:6082"
      @no_kill      = true
      @log_file     = STDOUT
    end

    def logger
      if !log_file.respond_to?(:write)
        STDOUT.reopen(File.open(@log_file, (File::WRONLY | File::APPEND | File::CREAT)))
        @logger = Logger.new(STDOUT)
      else      
        @logger = Logger.new(@log_file)
      end
    end

  end

end