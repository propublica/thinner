require 'helper'

class TestClient < Test::Unit::TestCase

  context "a thinner client" do

    setup do
      @client = Thinner::Client.new(URLS)
    end

    should "purge urls" do
      @client.run!
      assert_equal @client.purged_urls, URLS
    end

  end

  context "a thinner purger" do

    setup do
      @purger = Thinner::Purger.new(URLS)
    end

    should "fork a client" do
      @purger.purge!
      assert Thinner::Purger.job_ids.length > 0
    end

  end

end
