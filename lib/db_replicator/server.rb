module DbReplicator
  class Server
    include ActiveModel::Model
    include DbReplicator::Logger

    attr_accessor :identifier, :ip, :app_path, :environment, :user

    def initialize
      yield self if block_given?
    end

    def transfer_database_to(server)
      create_mysqldump_for_database(dbconfig)
      Dir.mktmpdir do |tmpdir|
        filename = download mysqldump_destination, tmpdir
        mysqldump_path = server.upload filename, mysqldump_destination
        server.import_mysql_dump(mysqldump_path)
      end
    end

    def download(remote_path, local_path)
      filename = ""
      log "Downloading #{remote_path} to #{local_path}", "Download complete!" do
        pb = ProgressBar.create(format: '%t %B %p%% %a')
        Net::SCP.download!(@ip, user, remote_path, local_path) do |_, name, sent, total|
          pb.total = total
          pb.progress = sent
          filename = Pathname.new(local_path).join(name).to_s
        end
        filename
      end
    end

    def upload(local_path, remote_path)
      log "Uploading #{local_path} to #{remote_path}", "Upload complete!" do
        pb = ProgressBar.create(format: '%t %B %p%% %a')
        Net::SCP.upload!(server.ip, user, filename, mysqldump_destination) do |_, _, sent, total|
          pb.total = total
          pb.progress = sent
        end
      end
    end

    def import_mysql_dump(path)
      log "Importing mysql dump #{path} with config #{dbconfig}", "Database imported!" do
        execute_command %Q(mysql -h #{dbconfig.host} -P #{dbconfig.port} -u #{dbconfig.username} --password='#{dbconfig.password}' #{dbconfig.database} < #{path})
      end
    end

    private

      def dbconfig
        @_dbconfig ||= begin
          hash = execute_command(%Q(RAILS_ENV=#{environment} bundle exec rails runner 'puts ActiveRecord::Base.configurations[:#{environment}.to_s].to_json'))
          hash = JSON.parse hash
          DatabaseConfiguration.new(hash)
        end
      end

      def create_mysqldump_for_database(dbconfig)
        log "Running mysqldump for database #{dbconfig.database}", "MySQL dump created at #{mysqldump_destination}" do
          execute_command %Q(mysqldump -h #{dbconfig.host} -P #{dbconfig.port} -u #{dbconfig.username} --password=#{dbconfig.password} #{dbconfig.database} > #{mysqldump_destination})
        end
      end

      def execute_command(command, in_path = @app_path)
        stdout = ""
        Net::SSH.start(@ip, user) do |ssh|
          ssh.exec "source $HOME/.bashrc; source $HOME/.bash_profile; source $HOME/.rbenvrc; cd #{in_path}; #{command}" do |ch, stream, data|
            stdout << data if stream == :stdout
          end
        end
        stdout
      end

      def mysqldump_destination
        @_mysqldump_destination ||= "/tmp/#{Time.now.to_s(:nsec)}.sql"
      end

  end
end
