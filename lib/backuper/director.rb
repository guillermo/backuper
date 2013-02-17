module Backuper
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

end
