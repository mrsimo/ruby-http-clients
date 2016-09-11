require 'excon'
Excon.defaults[:ssl_verify_peer] = false

module HTTPClients
  class ExconClient
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def name
      "Excon"
    end

    def run_once
      Excon.get(endpoint)
    end

    def response_ok?(response)
      response.status == 200
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
