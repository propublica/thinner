module RollingPurge

  ROOT               = File.expand_path "#{File.dirname __FILE__}/.."
  VERSION            = File.read("#{ROOT}/VERSION").chomp
  PROCESS_IDENTIFIER = "RollingPurge"

  class << self; attr_accessor :configuration; end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

  def self.stop!
    Purger.stop!
  end

  def self.purge! urls
    Purger.new(urls).purge!
  end

end

require "klarlack"
require "logger"
require "#{RollingPurge::ROOT}/lib/rolling_purge/configuration"
require "#{RollingPurge::ROOT}/lib/rolling_purge/client"
require "#{RollingPurge::ROOT}/lib/rolling_purge/purger"
