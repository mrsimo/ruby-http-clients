require 'http'

module HTTPClients
  class HTTPClient
    def initialize(endpoint, persistent)
      @endpoint   = endpoint
      @persistent = persistent
    end

    def name
      "http.rb"
    end

    def run_once
      HTTP.get(endpoint, ssl_context: unsafe_context)
    end

    def run_once_persistent
      persistent_connection.get("", ssl_context: unsafe_context).tap(&:flush)
    end

    def response_ok?(response)
      response.code == 200
    end

    private

    attr_reader :endpoint, :persistent

    def unsafe_context
      @unsafe_context ||= OpenSSL::SSL::SSLContext.new.tap do |context|
        context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def persistent_connection
      @persistent_connection ||= HTTP.persistent(endpoint)
    end
  end
end
