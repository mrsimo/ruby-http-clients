require 'typhoeus'

module HTTPClients
  class TyphoeusClient < BaseClient
    def name
      "Typhoeus"
    end

    def run_once
      Typhoeus.get(endpoint, ssl_verifypeer: false)
    end
    alias run_once_persistent run_once

    def setup_parallel
      @hydra = Typhoeus::Hydra.new max_concurrency: 5
    end

    def run_once_parallel
      request = Typhoeus::Request.new(endpoint, ssl_verifypeer: false)
      @hydra.queue(request)
      request
    end

    def fire_parallel
      @hydra.run
    end

    def response_ok?(request_or_response)
      response = if request_or_response.is_a?(Typhoeus::Response)
                   request_or_response
                 else
                   request_or_response.response
                 end

      response.code == 200
    end

    private

    attr_reader :endpoint, :persistent, :parallel
  end
end
