# frozen_string_literal: true

module ChatKit
  class Session
    class ChatKitConfiguration
      # Configuration for chat history retention.
      # When omitted, history is enabled by default with no limit on recent_threads (nil).
      #
      # Source: https://platform.openai.com/docs/api-reference/chatkit/sessions/create#chatkit_sessions_create-chatkit_configuration-history
      class History
        # @!attribute [r] enabled
        #  @return [Boolean, nil]
        attr_accessor :enabled

        # @!attribute [r] recent_threads
        #  @return [Integer, nil]
        attr_accessor :recent_threads

        # @param enabled [Boolean, nil] - optional - Enable automatic thread title generation.
        # @param recent_threads [Integer, nil] - optional - Number of recent threads to keep in history.
        def initialize(enabled: Session::Defaults::ENABLED, recent_threads: nil)
          @enabled = enabled
          @recent_threads = recent_threads
        end

        class << self
          def build(enabled: nil, recent_threads: nil)
            new(enabled:, recent_threads:)
          end

          # @param data [Hash, nil]
          #   @return [History]
          def deserialize(data)
            new(
              enabled: data&.dig("enabled"),
              recent_threads: data&.dig("recent_threads")
            )
          end
        end

        # @return [Hash]
        def serialize
          {
            enabled:,
            recent_threads:,
          }.compact
        end
      end
    end
  end
end
