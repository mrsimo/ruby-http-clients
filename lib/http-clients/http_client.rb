require 'http'

module HTTPClients
  class HTTPClient
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def name
      "http.rb"
    end

    def run_once
      HTTP.get(endpoint, ssl_context: unsafe_context)
    end

    def response_ok?(response)
      response.code == 200
    end

    private

    attr_reader :endpoint

    def unsafe_context
      @unsafe_context ||= OpenSSL::SSL::SSLContext.new.tap do |context|
        context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
  end
end
