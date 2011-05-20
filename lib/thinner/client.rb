require 'logger'

module Thinner

  # A Thinner::Client runs as a background process and purges a list of urls
  # in batches.
  class Client

    # A list of successfully purged urls.
    attr_reader :purged_urls

    # The list of Errors we want to catch.
    ERRORS = [Varnish::Error, Varnish::BrokenConnection, Varnish::CommandFailed, Timeout::Error, Errno::ECONNREFUSED]

    # Before purging, each Thinner::Client grabs various configuration settings
    # and makes a copy of the passed in urls.
    def initialize(urls)
      @batch        = Thinner.configuration.batch_length
      @timeout      = Thinner.configuration.sleep_time
      @varnish      = Varnish::Client.new Thinner.configuration.server
      @log_file     = Thinner.configuration.log_file
      @purged_urls  = []
      @urls         = Array.new urls
      @length       = @urls.length
      logger
      handle_errors
    end

    # Kickstart the purging process and loop through the array until there aren't
    # any urls left to purge. Each time the loop runs it will update the process
    # label with the first url in the list.
    def run!
      while @urls.length > 0
        @current_job = @urls.slice! 0, @batch
        $0 = "#{PROCESS_IDENTIFIER}: purging #{@current_job.first}"
        purge_urls
        sleep @timeout
      end
      close_log
    end

    private

    # Once a batch is ready the Client fires off purge requests on the list of
    # urls.
    def purge_urls
      @current_job.each do |url|
        begin
          @varnish.start if @varnish.stopped?
          while(!@varnish.running?) do sleep 0.1 end
          if @varnish.purge :url, url
            @logger.info "Purged url: #{url}"
            @purged_urls << url
          else
            @logger.warn "Could not purge: #{url}"
          end
        rescue *ERRORS => e
          @logger.warn "Error on url: #{url}, message: #{e}"
          sleep @timeout
        end
      end
    end

    # Trap certain signals so the Client can report back the progress of the
    # job and close the log.
    def handle_errors
      trap('HUP')  { }
      trap('TERM') { close_log; Process.exit! }
      trap('KILL') { close_log; Process.exit! }
      trap('INT')  { close_log; Process.exit! }
    end

    # The logger redirects all STDOUT writes to a logger instance.
    def logger
      if !@log_file.respond_to?(:write)
        STDOUT.reopen(File.open(@log_file, (File::WRONLY | File::APPEND | File::CREAT)))
      end
      @logger = Logger.new(STDOUT)
    end

    # Log the purged urls and exit the process.
    def close_log
      @logger.info "Purged #{@purged_urls.length} of #{@length} urls."
      @logger.info "Exiting..."
    end

  end

end
