require 'libarchive'

module Debeasy
  class Package
    
    attr_reader :path, :package
    attr_reader :control_file_contents
    attr_reader :preinst_contents, :prerm_contents
    attr_reader :postinst_contents, :postrm_contents

    def initialize(path)
      @path = path
      @package = Archive.read_open_filename(path)
      @fields = {}
      extract_files
      parse_control_file
    end

    def fields
      @fields.keys
    end

    def method_missing(m, *args, &block)
      @fields[m.to_s]
    end

    private

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
      end
    end

    def parse_control_file
      @control_file_contents.scan(/^([\w-]+?): (.*?)\n(?! )/m).each do |entry|
        field, value = entry
        @fields[field.gsub("-", "_").downcase] = value
      end
    end

  end
end
