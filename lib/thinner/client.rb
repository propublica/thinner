module Thinner

  class Client

    attr_reader :purged_urls

    ERRORS = [Varnish::Error, Varnish::BrokenConnection, Varnish::CommandFailed, Timeout::Error]

    def initialize(urls)
      @batch        = Thinner.configuration.batch_length
      @timeout      = Thinner.configuration.sleep_time
      @varnish      = Varnish::Client.new Thinner.configuration.server
      @logger       = Thinner.configuration.logger
      @purged_urls  = []
      @urls         = Array.new urls
      handle_errors
    end

    def run!
      while @urls.length > 0
        @current_job = @urls.slice! 0, @batch
        $0 = "#{PROCESS_IDENTIFIER}: purging #{@current_job.first}"
        purge_urls
        sleep @timeout
      end
    end

    def purge_urls
      @current_job.each do |url|
        begin
          if @varnish.purge :url, url
            log! "Purged url: #{url}"
            @purged_urls << url
          else
            log! "Could not purge: #{url}"
          end
        rescue *ERRORS => e
          @logger.warn "Error on url: #{url}, message: #{e}"
          sleep @timeout
        end
      end
    end

    def log!(message)
      @logger.info "#{message}"
    end

    def handle_errors
      trap('TERM') { close_log }
      trap('KILL') { close_log }
      trap('INT')  { close_log }
    end

    def close_log
      @logger.close
      exit
    end

  end

end
