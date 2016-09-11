require 'curb'

module HTTPClients
  class CurbClient
    OK_STATUS = "200 OK".freeze

    def initialize(endpoint)
      @endpoint = endpoint
    end

    def name
      "Curb"
    end

    def run_once
      Curl::Easy.new(endpoint).tap do |curl|
        curl.ssl_verify_peer = false
        curl.perform
      end
    end

    def response_ok?(response)
      response.status == OK_STATUS
    end

    private

    attr_reader :endpoint
  end
end
