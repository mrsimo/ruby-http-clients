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
    alias run_once_parallel run_once_persistent

    def response_ok?(response)
      response == OK_STATUS
    end

    private

    attr_reader :endpoint, :persistent, :parallel

    def persistent_connection
      @persistent_connection ||= Curl::Easy.new
    end
  end
end
