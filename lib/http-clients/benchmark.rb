require 'benchmark'
require 'terminal-table'

module HTTPClients
  class Benchmark
    def initialize(endpoint, number:, persistent: false, parallel: false)
      @endpoint   = endpoint
      @number     = number
      @persistent = persistent
      @parallel   = parallel
      @table      = Terminal::Table.new(
        title: title,
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
          client.setup_parallel if parallel

          number.times do
            times << ::Benchmark.realtime do
              if persistent
                responses << client.run_once_persistent
              elsif parallel
                responses << client.run_once_parallel
              else
                responses << client.run_once
              end
            end
          end

          client.fire_parallel if parallel
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

    attr_reader :endpoint, :number, :table, :persistent, :parallel

    def clients
      [
        NetHTTPClient.new(endpoint, persistent, parallel),
        CurbClient.new(endpoint, persistent, parallel),
        TyphoeusClient.new(endpoint, persistent, parallel),
        RestClientClient.new(endpoint, persistent, parallel),
        HTTPClient.new(endpoint, persistent, parallel),
        ExconClient.new(endpoint, persistent, parallel),
      ]
    end

    def title
      options =
        if parallel
          "in parallel "
        elsif persistent
          "with persistent connection "
        else
          ""
        end

      "#{number} requests #{options}against #{endpoint}"
    end

    def in_ms(seconds)
      "#{'%.2f' % (seconds * 1000).round(2)}ms"
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
