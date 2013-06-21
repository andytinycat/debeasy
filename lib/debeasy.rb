require "debeasy/version"
require "debeasy/package"

module Debeasy
  def self.read(path)
    Debeasy::Package.new(path)
  end
end
