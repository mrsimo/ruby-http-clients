require 'excon'
Excon.defaults[:ssl_verify_peer] = false

module HTTPClients
  class ExconClient
    def initialize(endpoint, persistent)
      @endpoint   = endpoint
      @persistent = persistent
    end

    def name
      "Excon"
    end

    def run_once
      Excon.get(endpoint)
    end

    def run_once_persistent
      persistent_connection.get
    end

    def response_ok?(response)
      response.status == 200
    end

    private

    attr_reader :endpoint, :persistent

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
