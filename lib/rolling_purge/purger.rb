module RollingPurge

  class Purger

    def initialize(urls)
      @urls = urls
    end

    def purge!
      self.class.stop!
      puts "==== Starting purge see: #{RollingPurge.configuration.log_file} for finished urls."
      client_id = fork {
        Client.new(@urls).run!
      }
      Process.detach(client_id)
    end

    # Helpful way to find pids by prefix from resque.
    def self.job_ids
      lines = `ps -A -o pid,command | grep #{PROCESS_IDENTIFIER}`.split("\n").map do |line|
        line.split(' ')[0].to_i
      end
    end

    def self.stop!
      job_ids.each do |pid|
        begin
          Process.kill("KILL", pid.to_i) rescue nil
          puts "==== Killing process: #{pid}"
        rescue Errno::ESRCH
        end
      end
    end

  end

end
