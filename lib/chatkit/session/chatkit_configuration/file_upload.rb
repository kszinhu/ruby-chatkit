# frozen_string_literal: true

module ChatKit
  class Session
    class ChatKitConfiguration
      # Configuration for upload enablement and limits.
      # When omitted, uploads are disabled by default (max_files 10, max_file_size 512 MB).
      #
      # Source: https://platform.openai.com/docs/api-reference/chatkit/sessions/create#chatkit_sessions_create-chatkit_configuration-file_upload
      class FileUpload
        module Defaults
          MAX_FILE_SIZE = 512
          MAX_FILES = 10
        end

        # @!attribute [r] enabled
        #  @return [Boolean, nil]
        attr_accessor :enabled

        # @!attribute [r] max_file_size
        #  @return [Integer, nil]
        attr_accessor :max_file_size
        # @!attribute [r] max_files
        #  @return [Integer, nil]
        attr_accessor :max_files

        # @param enabled [Boolean, nil] - optional - Enable automatic thread title generation.
        # @param max_file_size [Integer, nil] - optional - Maximum file size in MB.
        # @param max_files [Integer, nil] - optional - Maximum number of files.
        def initialize(
          enabled: Session::Defaults::ENABLED,
          max_file_size: Defaults::MAX_FILE_SIZE,
          max_files: Defaults::MAX_FILES
        )
          @enabled = enabled
          @max_file_size = max_file_size
          @max_files = max_files
        end

        class << self
          def build(max_file_size: nil, max_files: nil, enabled: nil)
            new(enabled:, max_file_size:, max_files:)
          end

          # @param data [Hash, nil]
          #  @return [FileUpload]
          def deserialize(data)
            new(
              enabled: data&.dig("enabled"),
              max_file_size: data&.dig("max_file_size"),
              max_files: data&.dig("max_files")
            )
          end
        end

        # @return [Hash]
        def serialize
          {
            enabled:,
            max_file_size:,
            max_files:,
          }.compact
        end
      end
    end
  end
end
