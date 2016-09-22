require 'rest-client'

module HTTPClients
  class RestClientClient < BaseClient
    def name
      "REST Client"
    end

    def run_once
      RestClient::Resource.new(endpoint, verify_ssl: OpenSSL::SSL::VERIFY_NONE).get
    end

    def response_ok?(response)
      response.code == 200
    end
  end
end
