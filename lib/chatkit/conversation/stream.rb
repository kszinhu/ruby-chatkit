# frozen_string_literal: true

module ChatKit
  class Conversation
    # Represents a stream of conversation data.
    class Stream
      # @param chunks [Array<Hash>] The array of streamed chunks.
      def initialize(chunks)
        @chunks = chunks
      end

      def stream!(&)
        @chunks.body.each do |chunk|
          parser.feed(chunk) do |_, data|
            process!(data, &)
          end
        end
      end

    private

      # @param data [String] The raw data chunk.
      # @yield [parsed_data] Yields the parsed data.
      #  @return [void]
      def process!(data, &)
        parsed_data = JSON.parse(data)

        yield(parsed_data) if block_given?
      end

      # @return [EventStreamParser::Parser]
      def parser
        @parser ||= EventStreamParser::Parser.new
      end
    end
  end
end
