# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  # Use the cassettes directory under spec for storing recordings
  config.cassette_library_dir = "spec/cassettes"

  # Use webmock to handle HTTP interactions
  config.hook_into :webmock

  # Configure to record new episodes when no cassette exists
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method uri headers body],
  }

  # Filter sensitive data - replace API keys and secrets with placeholder values
  config.filter_sensitive_data("<OPENAI_API_KEY>") do |interaction|
    # Extract API key from Authorization header
    auth_header = interaction.request.headers["Authorization"]&.first
    auth_header.split("Bearer ").last if auth_header&.include?("Bearer ")
  end

  # Filter client secrets from response bodies
  config.filter_sensitive_data("<CLIENT_SECRET>") do |interaction|
    if interaction.response.body.include?("client_secret")
      begin
        response_body = JSON.parse(interaction.response.body)
        response_body["client_secret"] if response_body.is_a?(Hash)
      rescue JSON::ParserError
        nil
      end
    end
  end

  # Filter workflow ID from environment variable
  config.filter_sensitive_data("<WORKFLOW_ID>") do |_interaction|
    ENV.fetch("WORKFLOW_ID", nil)
  end

  # Filter workflow IDs from request and response bodies
  config.filter_sensitive_data("<WORKFLOW_ID>") do |interaction|
    # From request body
    if interaction.request.body&.include?("workflow")
      begin
        request_body = JSON.parse(interaction.request.body)
        workflow_data = request_body["workflow"]
        workflow_data["id"] if workflow_data.is_a?(Hash)
      rescue JSON::ParserError
        nil
      end
    end
  end

  config.filter_sensitive_data("<WORKFLOW_ID>") do |interaction|
    # From response body
    if interaction.response.body&.include?("workflow")
      begin
        response_body = JSON.parse(interaction.response.body)
        workflow_data = response_body["workflow"]
        workflow_data["id"] if workflow_data.is_a?(Hash)
      rescue JSON::ParserError
        nil
      end
    end
  end

  # Filter session IDs from responses
  config.filter_sensitive_data("<SESSION_ID>") do |interaction|
    if interaction.response.body&.include?('"id"')
      begin
        response_body = JSON.parse(interaction.response.body)
        response_body["id"] if response_body.is_a?(Hash) && response_body["object"] == "chatkit.session"
      rescue JSON::ParserError
        nil
      end
    end
  end

  # Filter user IDs to protect user privacy
  config.filter_sensitive_data("<USER_ID>") do |interaction|
    # From request body
    if interaction.request.body&.include?("user")
      begin
        request_body = JSON.parse(interaction.request.body)
        request_body["user"] if request_body.is_a?(Hash)
      rescue JSON::ParserError
        nil
      end
    end
  end

  config.filter_sensitive_data("<USER_ID>") do |interaction|
    # From response body
    if interaction.response.body&.include?("user")
      begin
        response_body = JSON.parse(interaction.response.body)
        response_body["user"] if response_body.is_a?(Hash)
      rescue JSON::ParserError
        nil
      end
    end
  end

  # Filter timestamps and dynamic values
  config.filter_sensitive_data("<EXPIRES_AT>") do |interaction|
    if interaction.response.body&.include?("expires_at")
      begin
        response_body = JSON.parse(interaction.response.body)
        response_body["expires_at"] if response_body.is_a?(Hash)
      rescue JSON::ParserError
        nil
      end
    end
  end

  # Configure to ignore certain headers that might change between requests
  config.ignore_request do |request|
    # Ignore requests that don't match the OpenAI API
    !request.uri.include?("api.openai.com")
  end

  # Allow real HTTP connections for development/debugging when VCR_OFF is set
  config.allow_http_connections_when_no_cassette = false
  config.ignore_request { true } if ENV["VCR_OFF"] == "true"

  # Configure before_record hook to clean up responses
  config.before_record do |interaction|
    # Remove or modify headers that might contain sensitive information
    interaction.request.headers.delete("User-Agent")
    interaction.response.headers.delete("Set-Cookie") if interaction.response.headers["Set-Cookie"]

    # Clean up response timing headers
    interaction.response.headers.delete("X-Request-Id") if interaction.response.headers["X-Request-Id"]
    interaction.response.headers.delete("CF-Ray") if interaction.response.headers["CF-Ray"]
  end
end
