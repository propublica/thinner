module RollingPurge

  class Client

    attr_reader :purged_urls

    def initialize(urls)
      @urls         = urls
      @varnish      = Varnish::Client.new RollingPurge.configuration.server
      @logger       = RollingPurge.configuration.logger
      @purged_urls  = []
    end

    def run!
      @urls.each do |url|
        if @varnish.purge :url, url
          log! "Purged url: #{url}"
          @purged_urls << url
        end
      end
    end

    def log!(message)
      @logger.write "==== #{message}\n"
    end
  end

end