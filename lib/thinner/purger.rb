module Thinner
  # A Thinner::Purger dispatches a client and ensures only one instance of a
  # Thinner::Client is running at a given time.
  class Purger
    # Each Purger accepts a list of urls to pass on to the client to purge.
    def initialize(urls)
      @urls = urls
    end

    # After the configuration is in place and the Purger has a list of urls,
    # it can fork a client process to run in the background. By default the
    # Purger will kill any old Thinner::Client processes still running so as
    # to not double up on purge requests.
    def purge!
      self.class.stop! unless Thinner.configuration.no_kill
      puts "==== Starting purge see: #{Thinner.configuration.log_file} for finished urls."
      client_id = fork {
        Client.new(@urls).run!
      }
      Process.detach(client_id)
    end

    # A list of Thinner::Client process ids -- adapted from resque.
    def self.job_ids
      lines = `ps -A -o pid,command | grep #{PROCESS_IDENTIFIER}`.split("\n").map do |line|
        line.split(' ')[0].to_i
      end
    end

    # Before we spin up a new client each running process is killed by pid. Each
    # killed process id is logged in the Thinner log file.
    def self.stop!
      job_ids.each do |pid|
        begin
          Process.kill("KILL", pid.to_i)
          puts "==== Killing process: #{pid}"
        rescue Errno::ESRCH
        end
      end
    end

  end

end
