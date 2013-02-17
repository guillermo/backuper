require 'archive/tar/minitar'
require 'zlib'

module Backuper
  class StorageLogic
    include Log
    def initialize(storage)
      @storage = storage
      @time = Time.now.utc.to_i
      i "Current tar path: #{current_tar_path}"
      @file = File.open(current_tar_path, "wb")
      @gzip = Zlib::GzipWriter.new(@file)
      @tar  = Archive::Tar::Minitar::Writer.open(@gzip)
    end

    def current_tar_name
      "#{@time.to_s}.tar.gz"
    end

    def current_tar_path
      File.join(backups_dir, current_tar_name)
    end

    def backups_dir
      dir = File.expand_path(File.join("~",".backuper","backups"))
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      dir
    end

    def save(type, path)
      i "Saving #{path}"
      if type == :dir
        save_dir(path)
      else
        save_file(path)
      end
    end

    def save_file(path)
      path = File.expand_path(path)
      stat = File.stat(path)
      inode = stat.ino
      mtime = stat.mtime.to_i
      mode = stat.mode
      uid = stat.uid
      gid = stat.gid

      data_path = "#{mtime}-#{inode}"
      f = File.open(path,"r")
      @storage.set(".files/#{data_path}", f)

      size = data_path.size
      @tar.add_file_simple(path,:mode => mode, :mtime => mtime, :uid => uid, :gid => gid, :size => data_path.size) do |io|
        io.write data_path
      end
    ensure
      f.close
    end

    def save_dir(path)
      stat = File.stat(path)
      mtime = stat.mtime
      mode = stat.mode
      uid = stat.uid
      gid = stat.gid
      @tar.mkdir(path,:mode => mode, :mtime => mtime, :uid => uid, :gid => gid)
    end

    def close
      @tar.close
      @gzip.close
      # @file.close

      File.open(current_tar_path,"r") do |f|
        @storage.set(current_tar_name,f)
      end
    end
  end

end
