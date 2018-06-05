require 'benchmark'
require 'terminal-table'

module HTTPClients
  class Benchmark
    def initialize(endpoint, number:, persistent: false, concurrent: false, client: nil)
      @endpoint   = endpoint
      @number     = number
      @persistent = persistent
      @concurrent = concurrent
      @client     = client
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
      rows = []

      clients.each do |client|
        responses = []
        times     = []
        all_ok    = false

        total_time = ::Benchmark.realtime do
          client.setup_concurrent if concurrent

          number.times do
            times << ::Benchmark.realtime do
              if persistent
                responses << client.run_once_persistent
              elsif concurrent
                responses << client.run_once_concurrent
              else
                responses << client.run_once
              end
            end
          end

          client.fire_concurrent if concurrent
        end

        all_ok = responses.all? { |response| client.response_ok?(response) }

        rows << [
          client.name,
          { value: in_ms(total_time / number), alignment: :right },
          { raw: total_time, value: in_ms(total_time), alignment: :right },
          responses_ok(all_ok)]
      end

      rows.sort_by { |row| row[2][:raw] }.each { |row| table << row }

      puts table
    end

    private

    attr_reader :endpoint, :number, :table, :persistent, :concurrent, :client

    def clients
      clients = [
        NetHTTPClient.new(endpoint, persistent, concurrent),
        CurbClient.new(endpoint, persistent, concurrent),
        TyphoeusClient.new(endpoint, persistent, concurrent),
        RestClientClient.new(endpoint, persistent, concurrent),
        HTTPClient.new(endpoint, persistent, concurrent),
        ExconClient.new(endpoint, persistent, concurrent),
        FaradayNetHttpClient.new(endpoint, persistent, concurrent),
        PatronClient.new(endpoint, persistent, concurrent),
        HTTPartyClient.new(endpoint, persistent, concurrent),
      ]

      if client
        clients.select! { |c| c.name == client }
      end

      if persistent
        clients.select! { |c| c.respond_to?(:run_once_persistent) }
      end

      if concurrent
        clients.select! { |c| c.respond_to?(:run_once_concurrent) }
      end

      clients
    end

    def title
      options =
        if concurrent
          "concurrently "
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
