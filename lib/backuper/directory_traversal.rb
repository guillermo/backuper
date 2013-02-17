
module Backuper
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
