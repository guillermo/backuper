module Backuper
  class Director
    include Log

    def initialize(options = {})
      @options = options
      @storage = Storage::S3.new(options[:storage])
      @storage_logic = StorageLogic.new(@storage)
      @directory_traversal = DirectoryTraversal.new(@options[:directory])

      i "Starting backup"
      @directory_traversal.start do |type, entry|
        @storage_logic.save(type, entry)
      end
      i "Finishing backup. Uploading sync files"
      @storage_logic.close
      i "Backup finish"
    end
  end

end
