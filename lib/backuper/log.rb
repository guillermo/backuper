

module Backuper
  module Log
    def e(msg)
      log(:error, msg)
    end

    def i(msg)
      log(:inform, msg)
    end

    def d(msg)
      log(:debug,msg)
    end

    protected

    def log(severity,msg)
      $stderr.puts("%s - %5s - %s" % [Time.now.asctime, severity.to_s, msg])
    end
  end
end
