require 'helper'

class TestClient < Test::Unit::TestCase

  context "a varnish client" do

    setup do
      Thinner.configure { }
      @urls = ["/"]
      @client = Thinner::Client.new(@urls)
      @client.instance_variable_set('@server', @varnish)
    end

    should "purge urls" do
      begin
        @client.run!
      rescue SystemExit
        assert_equal @client.purged_urls, @urls
      end
    end

  end

end
