require 'benchmark'
require 'terminal-table'

module HTTPClients
  class Benchmark
    def initialize(endpoint, number:)
      @endpoint = endpoint
      @number   = number
      @table    = Terminal::Table.new(
        title: "#{number} requests against #{endpoint}",
        headings: [
          "",
          { value: "Average", alignment: :center },
          { value: "Total", alignment: :center },
          ""
        ],
        style: { border_x: "=", border_i: "x" }
      )
    end

    def run
      clients.each do |client|
        responses = []
        times     = []
        all_ok    = false

        total_time = ::Benchmark.realtime do
          number.times do
            times << ::Benchmark.realtime do
              responses << client.run_once
            end
          end
        end

        all_ok = responses.all? { |response| client.response_ok?(response) }

        table << [
          client.name,
          { value: in_ms(total_time / number), alignment: :right },
          { value: in_ms(total_time), alignment: :right },
          responses_ok(all_ok)]
      end

      puts table
    end

    private

    attr_reader :endpoint, :number, :table

    def clients
      [
        NetHTTPClient.new(endpoint),
        CurbClient.new(endpoint),
        TyphoeusClient.new(endpoint),
        RestClientClient.new(endpoint),
      ]
    end

    def in_ms(seconds)
      "#{(seconds * 1000).round(2)}ms"
    end

    def responses_ok(ok)
      if ok
        "All OK"
      else
        "Some failures"
      end
    end
  end
end
