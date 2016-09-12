require 'net/http'
require 'net/https'

module HTTPClients
  class NetHTTPClient
    OK_STATUS = "200".freeze

    def initialize(endpoint, persistent)
      @endpoint   = endpoint
      @persistent = persistent
      @uri      = URI.parse(endpoint)
      @ssl_mode = @uri.is_a?(URI::HTTPS)
      if persistent
        require 'net/http/persistent'
      end
    end

    def name
      "net/http"
    end

    def run_once
      http = Net::HTTP.new(uri.host, uri.port)

      if ssl_mode
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.request(Net::HTTP::Get.new(uri.request_uri))
    end

    def run_once_persistent
      persistent_connection.request uri
    end

    def response_ok?(response)
      response.code == OK_STATUS
    end

    private

    attr_reader :endpoint, :persistent, :uri, :ssl_mode

    def persistent_connection
      @persistent_connection ||= begin
        http = Net::HTTP::Persistent.new 'http-clients'
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE if ssl_mode
        http
      end
    end
  end
end
