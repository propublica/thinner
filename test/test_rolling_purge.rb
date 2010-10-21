require 'helper'

class TestClient < Test::Unit::TestCase
  context "a varnish client" do
    setup do
      RollingPurge.configure {}
      @varnish = Varnish::Client.new "127.0.0.1:6082"
      ensure_started
      @urls = ["/"]
      @client = RollingPurge::Client.new(@urls)
      @client.instance_variable_set('@server', @varnish)
    end

    should "purge urls" do
      @client.run!
      assert_equal @client.purged_urls, @urls
    end
  end

  def ensure_started
    @varnish.start if @varnish.stopped?
    while(!@varnish.running?) do sleep 0.1 end
  end

  def ensure_stopped
    @varnish.stop if @varnish.running?
    while(!@varnish.stopped?) do sleep 0.1 end
  end
end
