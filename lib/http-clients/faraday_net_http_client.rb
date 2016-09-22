require 'faraday'

module HTTPClients
  class FaradayNetHttpClient < BaseClient
    def name
      "Faraday+net/http"
    end

    def run_once
      connection.get
    end

    def run_once_persistent
      persistent_connection.get
    end

    def response_ok?(response)
      response.status == 200
    end

    private

    def persistent_connection
      @persistent_connection = Faraday.new(endpoint, ssl: { verify: false }) do |conn|
        conn.use Faraday::Adapter::NetHttpPersistent
      end
    end

    def connection
      @connection = Faraday.new(endpoint, ssl: { verify: false }) do |conn|
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
