module HTTPClients
  class BaseClient
    def initialize(endpoint, persistent, concurrent)
      @endpoint   = endpoint
      @persistent = persistent
      @concurrent = concurrent
      @uri        = URI.parse(endpoint)
    end

    def setup_concurrent
      # noop by default
    end

    def fire_concurrent
      # noop by default
    end

    private

    attr_reader :endpoint, :persistent, :concurrent, :uri
  end
end
