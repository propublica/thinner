module Thinner

  # The base location of the Thinner gem.
  ROOT               = File.expand_path "#{File.dirname __FILE__}/.."

  # The Thinner version.
  VERSION            = File.read("#{ROOT}/VERSION").chomp

  # The process label to run each Thinner::Client under.
  PROCESS_IDENTIFIER = "Thinner"

  # Set up the configuration instance as a class level accessor.
  class << self; attr_accessor :configuration; end

  # Set any thinner settings by passing in a block.
  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

  # Halt any running instances of Thinner::Client
  def self.stop!
    Purger.stop!
  end

  # Begin purging urls.
  def self.purge! urls
    Purger.new(urls).purge!
  end

end

require "klarlack"
require "logger"
require "#{Thinner::ROOT}/lib/thinner/configuration"
require "#{Thinner::ROOT}/lib/thinner/client"
require "#{Thinner::ROOT}/lib/thinner/purger"
