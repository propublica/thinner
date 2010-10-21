module RollingPurge

  ROOT               = File.expand_path "#{File.dirname __FILE__}/.."
  VERSION            = File.read("#{ROOT}/VERSION").chomp
  PROCESS_IDENTIFIER = "RollingPurge: purging urls"

  class << self; attr_accessor :configuration; end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

  def self.stop
    Purger.job_ids.each do |pid|
      puts "=== Killing process: #{pid}"
      Process.kill("KILL", pid)
    end
  end

end

require "klarlack"
require "logger"
require "#{RollingPurge::ROOT}/lib/rolling_purge/configuration"
require "#{RollingPurge::ROOT}/lib/rolling_purge/client"
require "#{RollingPurge::ROOT}/lib/rolling_purge/purger"
