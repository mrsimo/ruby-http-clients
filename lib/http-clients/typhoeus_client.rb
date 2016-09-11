require 'typhoeus'

module HTTPClients
  class TyphoeusClient
    def initialize(endpoint, persistent)
      @endpoint   = endpoint
      @persistent = persistent
    end

    def name
      "Typhoeus"
    end

    def run_once
      Typhoeus.get(endpoint, ssl_verifypeer: false)
    end

    def response_ok?(response)
      response.code == 200
    end

    private

    attr_reader :endpoint, :persistent
  end
end
