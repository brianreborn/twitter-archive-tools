#!/usr/bin/ruby
require 'json'
require 'zip'

class TwitterArchive
  ZIP_FILE_DATE_PATTERN = /twitter-([0-9]{4}-[0-9]{2}-[0-9]{2})-([0-9a-f]+)\.zip$/
  def initialize(dir, account)
    @dir = dir
    @archive_file_names = []
    Dir.open(dir) {|d|
      d.each {|file_name|
        if file_name =~ ZIP_FILE_DATE_PATTERN and $2 == account
          @archive_file_names.push(file_name)
        end
      }
    }
    @archive_file_names.sort!()
  end

  def each(&block) # {|zip_file, archive_date, is_last|
    @archive_file_names.each_with_index {|zip_file_name, index|
      Zip::File.open("#{@dir}/#{zip_file_name}") {|zip_file|
        zip_file_name =~ ZIP_FILE_DATE_PATTERN
        block.call(zip_file,
                   $1, # archive_date
                   index == @archive_file_names.size() - 1) # is_last
      }
    }
  end
end
