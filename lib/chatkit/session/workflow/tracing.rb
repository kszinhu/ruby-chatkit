# frozen_string_literal: true

module ChatKit
  class Session
    class Workflow
      # Optional tracing overrides for the workflow invocation. When omitted, tracing is enabled by default.
      #
      # Source: https://platform.openai.com/docs/api-reference/chatkit/sessions/create#chatkit_sessions_create-workflow-tracing
      class Tracing
        # @!attribute [r] enabled
        #  @return [Boolean, nil]
        attr_accessor :enabled

        # @param enabled [Boolean, nil] - optional - Enable tracing for the workflow.
        def initialize(enabled: Session::Defaults::ENABLED)
          @enabled = enabled
        end

        class << self
          def build(enabled: nil)
            new(enabled:)
          end

          # @param data [Hash, nil]
          #  @return [Tracing]
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
