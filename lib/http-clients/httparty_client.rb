require 'httparty'

module HTTPClients
  class HTTPartyClient < BaseClient
    def name
      "HTTParty"
    end

    def run_once
      HTTParty.get(endpoint, verify: false)
    end

    def response_ok?(response)
      response.code == 200
    end

  end
end
