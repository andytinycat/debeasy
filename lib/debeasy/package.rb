require 'libarchive'
require 'filemagic'
require 'digest'

module Debeasy
  class Error < RuntimeError; end
  class NotAPackageError < Error; end

  class Package
    
    attr_reader :path, :package_file
    attr_reader :control_file_contents, :filelist
    attr_reader :preinst_contents, :prerm_contents
    attr_reader :postinst_contents, :postrm_contents

    # Create a new Debeasy::Package object.
    #
    # Arguments:
    #   path: (String)

    def initialize(path)
      @path = path
      raise NotAPackageError, "#{path} is not a Debian package" unless is_package_file?
      @package_file = Archive.read_open_filename(path)
      @fields = {}
      @filelist = []
      extract_files
      parse_control_file
      generate_checksums
      get_size
      get_filename
    end

    # Lists all the available fields on the package.

    def fields
      @fields.keys
    end

    # Get package metadata as a hash.

    def to_hash
      @fields
    end

    def method_missing(m, *args, &block)
      @fields.has_key?(m.to_s) ? @fields[m.to_s] : nil
    end

    # Utility method to get the field in a hash-like way.

    def [](field)
      @fields.has_key?(field.to_s) ? @fields[field.to_s] : nil
    end

    private

    def is_package_file?
      fm = FileMagic.new
      if fm.file(@path) =~ /Debian binary package/
        true
      else
        false
      end
    end

    def get_size
      @fields["size"] = File.size(@path)
    end

    def get_filename
      @fields["filename"] = File.basename @path
    end

    def generate_checksums
      @fields["MD5sum"] = Digest::MD5.hexdigest(File.read @path)
      @fields["SHA1"] = Digest::SHA1.hexdigest(File.read @path)
      @fields["SHA256"] = Digest::SHA256.hexdigest(File.read @path)
    end

    # Poke inside the package to find the control file,
    # the pre/post install scripts, and a list of
    # all the files it will deploy.
    
    def extract_files
      while file = @package_file.next_header
        if file.pathname == "control.tar.gz"
          control_tar_gz = Archive.read_open_memory(@package_file.read_data)
          while control_entry = control_tar_gz.next_header
            case control_entry.pathname
            when "./control"
              @control_file_contents = control_tar_gz.read_data
            when "./preinst"
              @preinst_contents = control_tar_gz.read_data
            when "./prerm"
              @prerm_contents = control_tar_gz.read_data
            when "./postinst"
              @postinst_contents = control_tar_gz.read_data
            when "./postrm"
              @postrm_contents = control_tar_gz.read_data
            end
          end
        end
        if file.pathname == "data.tar.gz"
          data_tar_gz = Archive.read_open_memory(@package_file.read_data)
          while data_entry = data_tar_gz.next_header
            # Skip dirs; they're listed with a / as the last character
            @filelist << data_entry.pathname.sub(/^\./, "") unless data_entry.pathname =~ /\/$/
          end
        end
      end
    end

    # Parse the available fields out of the Debian control file.

    def parse_control_file
      @control_file_contents.scan(/^([\w-]+?): (.*?)\n(?! )/m).each do |entry|
        field, value = entry
        @fields[field.gsub("-", "_").downcase] = value
      end
      @fields["installed_size"] = @fields["installed_size"].to_i * 1024 unless @fields["installed_size"].nil?
    end

  end
end
