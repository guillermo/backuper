
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
