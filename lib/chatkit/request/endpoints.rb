# frozen_string_literal: true

module ChatKit
  module Request
    # Module defining API endpoints
    # Usage:
    #   Chatkit::Request::Endpoints.conversation_endpoint
    #   Chatkit::Request::Endpoints.sessions_endpoint
    #   etc.
    module Endpoints
      CONVERSATION = "/v1/chatkit/conversation"
      SESSIONS = "/v1/chatkit/sessions"
      FILES = "/v1/chatkit/files"

      class << self
        # Dynamically define methods for each endpoint constant
        # e.g., conversation_endpoint, sessions_endpoint, files_endpoint
        #
        # @return [String] The corresponding endpoint string
        ChatKit::Request::Endpoints.constants.each do |const_name|
          define_method "#{const_name.to_s.downcase}_endpoint" do
            ChatKit::Request::Endpoints.const_get(const_name)
          end
        end
      end
    end
  end
end
