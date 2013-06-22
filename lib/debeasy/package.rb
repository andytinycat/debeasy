require 'libarchive'

module Debeasy
  class Package
    
    attr_reader :path, :package
    attr_reader :control_file_contents, :filelist
    attr_reader :preinst_contents, :prerm_contents
    attr_reader :postinst_contents, :postrm_contents

    # Create a new Debeasy::Package object.
    #
    # Arguments:
    #   path: (String)

    def initialize(path)
      @path = path
      @package = Archive.read_open_filename(path)
      @fields = {}
      @filelist = []
      extract_files
      parse_control_file
    end

    # Lists all the available fields on the package.

    def fields
      @fields.keys
    end

    def method_missing(m, *args, &block)
      @fields.has_key?(m.to_s) ? @fields[m.to_s] : nil
    end

    private

    # Poke inside the package to find the control file,
    # the pre/post install scripts, and a list of
    # all the files it will deploy.
    
    def extract_files
      while file = @package.next_header
        if file.pathname == "control.tar.gz"
          control_tar_gz = Archive.read_open_memory(@package.read_data)
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
          data_tar_gz = Archive.read_open_memory(@package.read_data)
          while data_entry = data_tar_gz.next_header
            @filelist << data_entry.pathname.sub(/^\./, "")
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
    end

  end
end
