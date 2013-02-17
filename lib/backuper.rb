require "backuper/version"
require 'archive/tar/minitar'
require 'backuper/director'
require 'backuper/directory_traversal'
require 'backuper/storage_logic'
require 'backuper/storage'

# class Object
#   def i(msg)
#     $stderr.puts(File.basename(caller[0]) + " " + msg)
#   end
# end

module Backuper
  def self.backup(dir)
    Director.new(:directory => dir)
  end
end
