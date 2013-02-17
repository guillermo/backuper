require 'minitest/unit'
require 'backuper'

class BackuperTest < MiniTest::Unit::TestCase
  def setup
    @dir = File.expand_path(File.join(__FILE__,"..","backup_fixture"))
  end

  def test_backup
    backup = Backuper.backup(@dir, options)
  end
end
