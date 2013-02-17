require "backuper/version"
require 'archive/tar/minitar'

class Object
  def i(msg)
    $stderr.puts(File.basename(caller[0]) + " " + msg)
  end
end

module Backuper
  def self.backup(dir)
    Director.new(:directory => dir)
  end

  class Storage
    def initialize()
      @db = {}
    end

    def set(path,content)
      @db[path] = content
    end

    def get(path)
      @db[path]
    end

    def inspect
      @db.map do |k,v|
        "#{k} => #{v.inspect}\n"
      end
    end
  end

  class Director
    def initialize(options = {})
      @options = options
      @storage = Storage.new
      @storage_logic = StorageLogic.new(@storage)
      @directory_traversal = DirectoryTraversal.new(@options[:directory])

      @directory_traversal.start do |type, entry|
        @storage_logic.save(type, entry)
      end
      @storage_logic.close
    end
  end


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



  class DirectoryTraversal
    attr_reader :storage
    def initialize(dir)
      @backup_dir = dir
    end

    def start(&block)
      process_dir(@backup_dir,&block)
    end

    def process_dir(dir,&block)
      dir = Dir.open(dir)
      while(entry = dir.read)
        path = File.join(dir,entry)
        next if %w(. ..).include?(entry)
        if File.directory?(path)
          yield :dir, path
          process_dir(path, &block)
        else
          yield :file, path
        end
      end
    end

  end
end
