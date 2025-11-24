# frozen_string_literal: true

module ChatKit
  class FilesError < ChatKit::Error; end

  # Handles file uploads to the ChatKit API.
  class Files
    # @!attribute [rw] file
    #  @return [String]
    attr_accessor :file

    # @!attribute [rw] client_secret
    #  @return [String]
    attr_accessor :client_secret

    # @param client_secret [String] - The client secret for authentication.
    # @param file_path [File] - The path to the file to be uploaded.
    # @param client [ChatKit::Client] - The ChatKit client instance.
    def initialize(client_secret:, file:, client: Client.new)
      @client = client
      @client_secret = client_secret
      @file = file
    end

    class << self
      def upload!(client_secret:, file:, client: Client.new)
        new(client_secret:, file:, client:).upload!
      end
    end

    # Uploads a file to ChatKit.
    #
    # @return [ChatKit::Files::Response] The response object containing file metadata.
    # @raise [FilesError] If the upload fails.
    def upload!
      response = perform_request
      handle_response_errors(response)

      ChatKit::Files::Response.deserialize(response.parse)
    rescue StandardError => e
      raise FilesError, "File upload failed: #{e.message}"
    end

  private

    # Retrieves the files endpoint URL.
    # @return [String] The files endpoint URL.
    def files_endpoint
      ChatKit::Request::Endpoints.files_endpoint
    end

    # Performs the HTTP request to upload a file.
    #
    # @return [HTTP::Response] The HTTP response.
    def perform_request
      @client.connection
        .headers(files_header)
        .post(files_endpoint, form: { file: HTTP::FormData::File.new(@file) })
    end

    # Builds the headers for the file upload request.
    #
    # @raise [RuntimeError] If there is no active session.
    # @return [Hash] The request headers.
    def files_header
      raise SessionError, "No active session found" unless @client_secret

      ChatKit::Request::Headers.files_header.merge(
        "Authorization" => "Bearer #{@client_secret}"
      )
    end

    # Handles HTTP response errors by raising appropriate exceptions.
    #
    # @param response [HTTP::Response] The HTTP response to check.
    # @raise [FilesError] If the response indicates an error.
    def handle_response_errors(response)
      return unless response.code >= 300

      error_message = begin
        response.parse["error"]["message"]
      rescue StandardError
        "Request failed with status #{response.code}"
      end

      raise FilesError, error_message
    end
  end
end
