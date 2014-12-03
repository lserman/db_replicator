module DbReplicator
  class DatabaseConfiguration

    attr_reader :host, :port, :username, :password, :database

    def initialize(activerecord_hash)
      @host = activerecord_hash['host'] || fetch_host_from_makara_config(activerecord_hash) || 'localhost'
      @port = activerecord_hash.fetch('port', 3306)
      @username = activerecord_hash.fetch('username', 'root')
      @password = activerecord_hash.fetch('password', '')
      @database = activerecord_hash.fetch('database')
    end

    def to_s
      "host=#{host} port=#{port} username=#{username} password=[REDACTED] database=#{database}"
    end

    private

      def fetch_host_from_makara_config(hash)
        hash['makara']['connections'][0]['host'] if hash.include? 'makara'
      end

  end
end