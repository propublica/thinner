module Thinner

  ROOT               = File.expand_path "#{File.dirname __FILE__}/.."
  VERSION            = File.read("#{ROOT}/VERSION").chomp
  PROCESS_IDENTIFIER = "Thinner"

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
require "#{Thinner::ROOT}/lib/thinner/configuration"
require "#{Thinner::ROOT}/lib/thinner/client"
require "#{Thinner::ROOT}/lib/thinner/purger"
