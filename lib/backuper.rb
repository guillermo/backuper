require "backuper/version"
require 'archive/tar/minitar'
require 'backuper/log'
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
    Director.new(:directory => dir, :storage => {
      :provider => "AWS",
      :aws_access_key_id => ENV["AWS_ACCESS_KEY_ID"],
      :aws_secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"],
      :region => "eu-west-1",
      :bucket => "backup.cientifico.net" })
  end
end
