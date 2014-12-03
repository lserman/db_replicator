module DbReplicator
  class Localhost < Server
    include ActiveModel::Model

    def host
      'localhost'
    end

    def download(remote_path, local_path)
      raise "Can't import from localhost!"
    end

    def upload(local_path, remote_path)
      log "Skipping upload because the destination is local (file is at #{local_path})"
      local_path
    end

    private

      def execute_command(command, in_path = @app_path)
        output = ""
        Dir.chdir(in_path) { output = `#{command}` }
        output
      end

  end
end