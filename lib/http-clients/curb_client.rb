require 'curb'

module HTTPClients
  class CurbClient < BaseClient
    OK_STATUS = "200 OK".freeze

    def name
      "Curb"
    end

    def run_once
      curl = Curl::Easy.new(endpoint)
      curl.ssl_verify_peer = false
      curl.http_get
      curl.status
    end

    def run_once_persistent
      persistent_connection.ssl_verify_peer = false
      persistent_connection.url = endpoint
      persistent_connection.http_get
      persistent_connection.status
    end

    def setup_concurrent
      @multi = Curl::Multi.new
      @responses = {}
    end

    def run_once_concurrent
      curl = Curl::Easy.new(endpoint)
      curl.ssl_verify_peer = false
      curl.on_complete { |easy| @responses[curl] = easy }
      @multi.add(curl)
      curl
    end

    def fire_concurrent
      @multi.perform
    end


    def response_ok?(response)
      if response.is_a?(String)
        response == OK_STATUS
      else 
        @responses[response].status
      end
    end

    private

    def persistent_connection
      @persistent_connection ||= Curl::Easy.new
    end
  end
end
