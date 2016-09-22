require 'patron'

module HTTPClients
  class PatronClient < BaseClient
    def name
      "Patron"
    end

    def run_once
      Patron::Session.new(base_url: endpoint_without_path, insecure: true).get(uri.path)
    end

    def run_once_persistent
      connection.get(uri.path)
    end

    def response_ok?(response)
      response.status == 200
    end

    private

    def connection
      @connection ||= Patron::Session.new(base_url: endpoint_without_path, insecure: true)
    end

    def endpoint_without_path
      @endpoint_without_path ||= begin
                                    point = uri.dup
                                    point.path = ""
                                    point.to_s
                                  end
    end
  end
end
