require 'excon'
Excon.defaults[:ssl_verify_peer] = false

module HTTPClients
  class ExconClient < BaseClient
    def name
      "Excon"
    end

    def run_once
      Excon.get(endpoint)
    end

    def run_once_persistent
      persistent_connection.get
    end
    alias run_once_concurrent run_once_persistent

    def response_ok?(response)
      response.status == 200
    end

    private

    def unsafe_context
      @unsafe_context ||= OpenSSL::SSL::SSLContext.new.tap do |context|
        context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def persistent_connection
      @persistent_connection ||= Excon.new(endpoint, persistent: true)
    end
  end
end
