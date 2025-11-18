# frozen_string_literal: true

module ChatKit
  class Session
    # Optional overrides for ChatKit runtime configuration features
    #
    # Source: https://platform.openai.com/docs/api-reference/chatkit/sessions/create#chatkit_sessions_create-chatkit_configuration
    class ChatKitConfiguration
      # @!attribute [r] automatic_thread_titling
      #  @return [AutomaticThreadTitling]
      attr_accessor :automatic_thread_titling

      # @!attribute [r] file_upload
      #  @return [FileUpload]
      attr_accessor :file_upload

      # @!attribute [r] history
      #  @return [History]
      attr_accessor :history

      # @param automatic_thread_titling [Hash, nil] - optional - Configuration for automatic thread titling.
      # @param file_upload [Hash, nil] - optional - Configuration for upload enablement and limits.
      # @param history [Hash, nil] - optional - Configuration for chat history retention.
      def initialize(file_upload: nil, history: nil, automatic_thread_titling: nil)
        @automatic_thread_titling = setup_automatic_thread_titling(automatic_thread_titling)
        @file_upload = setup_file_upload(file_upload)
        @history = setup_history(history)
      end

      class << self
        def build(automatic_thread_titling: nil, file_upload: nil, history: nil)
          new(automatic_thread_titling:, file_upload:, history:)
        end

        # @param data [Hash, nil]
        #  @return [ChatKitConfiguration]
        def deserialize(data)
          automatic_thread_titling = AutomaticThreadTitling.deserialize(data&.dig("automatic_thread_titling"))
          file_upload = FileUpload.deserialize(data&.dig("file_upload"))
          history = History.deserialize(data&.dig("history"))

          new(automatic_thread_titling:, file_upload:, history:)
        end
      end

      # @return [Hash]
      def serialize
        {
          automatic_thread_titling: automatic_thread_titling.serialize,
          file_upload: file_upload.serialize,
          history: history.serialize,
        }.compact
      end

    private

      # @param automatic_thread_titling [Hash, nil]
      #  @return [AutomaticThreadTitling]
      def setup_automatic_thread_titling(automatic_thread_titling)
        return automatic_thread_titling if automatic_thread_titling.is_a?(AutomaticThreadTitling)

        AutomaticThreadTitling.build(**automatic_thread_titling.to_h)
      end

      # @param file_upload [Hash, nil]
      #  @return [FileUpload]
      def setup_file_upload(file_upload)
        return file_upload if file_upload.is_a?(FileUpload)

        FileUpload.build(**file_upload.to_h)
      end

      # @param history [Hash, nil]
      #  @return [History]
      def setup_history(history)
        return history if history.is_a?(History)

        History.build(**history.to_h)
      end
    end
  end
end
