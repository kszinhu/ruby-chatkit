# frozen_string_literal: true

module ChatKit
  class Session
    class ChatKitConfiguration
      # Configuration for automatic thread titling. When omitted, automatic thread titling is enabled by default.
      #
      # Source: https://platform.openai.com/docs/api-reference/chatkit/sessions/create#chatkit_sessions_create-chatkit_configuration-automatic_thread_titling
      class AutomaticThreadTitling
        # @!attribute [r] enabled
        #  @return [Boolean, nil]
        attr_accessor :enabled

        # @param enabled [Boolean, nil] - optional - Enable automatic thread title generation.
        def initialize(enabled: Session::Defaults::ENABLED)
          @enabled = enabled
        end

        class << self
          def build(enabled: nil)
            new(enabled:)
          end

          # @param data [Hash, nil]
          #  @return [AutomaticThreadTitling]
          def deserialize(data)
            new(
              enabled: data&.dig("enabled")
            )
          end
        end

        # @return [Hash]
        def serialize
          {
            enabled:,
          }.compact
        end
      end
    end
  end
end
