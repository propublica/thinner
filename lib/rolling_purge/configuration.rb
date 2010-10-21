module RollingPurge

  class Configuration

    attr_accessor :batch_length, :sleep_time, :server, :log_file, :kill

    def initialize
      @batch_length = 10
      @sleep_time   = 1
      @server       = "127.0.0.1:6082"
      @log_file     = STDOUT
      @no_kill         = true
    end

    def logger
      if !log_file.respond_to?(:write)
        real_path = File.expand_path(@log_file)
        FileUtils.mkdir_p(real_path) unless File.exist?(File.dirname(real_path))
        @logger   = File.open(real_path, (File::WRONLY | File::CREAT))
      else
        @logger   = @log_file
      end
    end

  end

end