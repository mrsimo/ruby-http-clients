require 'rest-client'

module HTTPClients
  class RestClientClient < BaseClient
    def name
      "REST Client"
    end

    def run_once
      RestClient::Resource.new(endpoint, verify_ssl: OpenSSL::SSL::VERIFY_NONE).get
    end
    alias run_once_persistent run_once
    alias run_once_parallel run_once

    def response_ok?(response)
      response.code == 200
    end

    private

    attr_reader :endpoint, :persistent, :parallel
  end
end
