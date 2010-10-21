module RollingPurge

  class Purger

    def initialize(urls)
      @batch   = RollingPurge.configuration.batch_length
      @timeout = RollingPurge.configuration.sleep_time
      @urls    = urls
    end

    def purge!
      urls = @urls
      client_id = fork {
        $0 = PROCESS_IDENTIFIER
        while urls.length > 0
          urls_to_purge = urls.slice! 0, @batch
          Client.new(urls_to_purge).run! if !urls_to_purge.nil?
          sleep @timeout
        end
      }
      Process.detach(client_id)
    end

    # Helpful way to find pids by prefix from resque.
    def self.job_ids
      `ps -A -o pid,command | grep "#{PROCESS_IDENTIFIER}"`.split("\n").map do |line|
        line.split(' ')[0]
      end
    end

  end

end
