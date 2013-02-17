module Backuper
  class StorageLogic
    def initialize(storage)
      @storage = storage
      @time = Time.now.utc.to_i
      @file = File.open(@time.to_s + ".tar", "wb")
      @tar  = Archive::Tar::Minitar::Writer.open(@file)
    end

    def save(type, path)
      if type == :dir
        save_dir(path)
      else
        save_file(path)
      end
    end

    def save_file(path)
      stat = File.stat(path)
      inode = stat.ino
      mtime = stat.mtime.to_i
      mode = stat.mode
      uid = stat.uid
      gid = stat.gid

      data_path = "#{mtime}-#{inode}"
      @storage.set(data_path, File.read(path))

      size = data_path.size
      @tar.add_file(path,:mode => mode, :mtime => mtime, :uid => uid, :gid => gid, :size => data_path.size) do |io|
        io.write data_path
      end
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
      @file.close
    end
  end

end
