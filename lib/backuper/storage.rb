require 'fog'
module Backuper
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
end

module Backuper
  class Storage::S3
    def initialize(options)
      bucket = options.delete(:bucket)
      @db = Fog::Storage.new(options)
      @bucket = @db.directories.get(bucket)
    end

    def get(path)
      @bucket.get(path)
    end

    def set(path,io)
      @bucket.files.create(
        :key => path,
        :body => io
      )
    end
  end
end
