require "debeasy/version"
require "debeasy/package"

module Debeasy
  # Read a package file; returns a Debeasy::Package object.

  def self.read(path)
    Debeasy::Package.new(path)
  end
end
