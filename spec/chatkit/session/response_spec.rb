# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChatKit::Session::Response do
  # Helper method to create sample data
  def sample_response_data
    {
      "id" => "sess_abc123",
      "object" => "session",
      "status" => "active",
      "chatkit_configuration" => {
        "automatic_thread_titling" => { "enabled" => true },
        "file_upload" => { "enabled" => false, "max_file_size" => 256, "max_files" => 5 },
        "history" => { "enabled" => true, "recent_threads" => 50 },
      },
      "client_secret" => "sk_test_secret_123",
      "expires_at" => "2025-12-01T00:00:00Z",
      "max_requests_per_1_minute" => 60,
      "rate_limits" => {
        "max_requests_per_1_minute" => 100,
      },
      "user" => {
        "id" => "user_123",
        "name" => "Test User",
        "email" => "test@example.com",
      },
      "workflow" => {
        "id" => "wf_workflow123",
        "state_variables" => { "key" => "value" },
        "tracing" => { "enabled" => true },
        "version" => "1.0.0",
      },
    }
  end

  describe ".new" do
    let(:workflow) { build(:workflow) }
    let(:chatkit_configuration) { build(:chatkit_configuration) }
    let(:rate_limits) { build(:rate_limits) }
    let(:user_data) { { "id" => "user_123", "name" => "Test User" } }

    context "when all required arguments are provided" do
      it "initializes with all provided values" do
        response = described_class.new(
          id: "sess_test123",
          object: "session",
          status: "active",
          chatkit_configuration:,
          client_secret: "sk_secret123",
          expires_at: "2025-12-01T00:00:00Z",
          max_requests_per_1_minute: 60,
          rate_limits:,
          user: user_data,
          workflow:
        )

        expect(response.id).to eq("sess_test123")
        expect(response.object).to eq("session")
        expect(response.status).to eq("active")
        expect(response.chatkit_configuration).to eq(chatkit_configuration)
        expect(response.client_secret).to eq("sk_secret123")
        expect(response.expires_at).to eq("2025-12-01T00:00:00Z")
        expect(response.max_requests_per_1_minute).to eq(60)
        expect(response.rate_limits).to eq(rate_limits)
        expect(response.user).to eq(user_data)
        expect(response.workflow).to eq(workflow)
      end
    end

    context "when handling different data types" do
      it "accepts string values for basic fields" do
        response = described_class.new(
          id: "sess_string_test",
          object: "custom_object",
          status: "pending",
          chatkit_configuration:,
          client_secret: "sk_different_secret",
          expires_at: "2026-01-01T12:00:00Z",
          max_requests_per_1_minute: 120,
          rate_limits:,
          user: user_data,
          workflow:
        )

        expect(response.id).to eq("sess_string_test")
        expect(response.object).to eq("custom_object")
        expect(response.status).to eq("pending")
        expect(response.client_secret).to eq("sk_different_secret")
        expect(response.expires_at).to eq("2026-01-01T12:00:00Z")
        expect(response.max_requests_per_1_minute).to eq(120)
      end

      it "accepts integer values for numeric fields" do
        response = described_class.new(
          id: "sess_numeric_test",
          object: "session",
          status: "active",
          chatkit_configuration:,
          client_secret: "sk_secret",
          expires_at: "2025-12-01T00:00:00Z",
          max_requests_per_1_minute: 0,
          rate_limits:,
          user: user_data,
          workflow:
        )

        expect(response.max_requests_per_1_minute).to eq(0)
      end

      it "accepts complex hash for user data" do
        complex_user = {
          "id" => "user_complex",
          "name" => "Complex User",
          "email" => "complex@example.com",
          "metadata" => { "role" => "admin", "permissions" => %w[read write] },
        }

        response = described_class.new(
          id: "sess_complex_user",
          object: "session",
          status: "active",
          chatkit_configuration:,
          client_secret: "sk_secret",
          expires_at: "2025-12-01T00:00:00Z",
          max_requests_per_1_minute: 60,
          rate_limits:,
          user: complex_user,
          workflow:
        )

        expect(response.user).to eq(complex_user)
        expect(response.user["metadata"]["role"]).to eq("admin")
      end
    end
  end

  describe "attribute accessors" do
    let(:response) do
      described_class.new(
        id: "sess_accessor_test",
        object: "session",
        status: "active",
        chatkit_configuration: build(:chatkit_configuration),
        client_secret: "sk_secret",
        expires_at: "2025-12-01T00:00:00Z",
        max_requests_per_1_minute: 60,
        rate_limits: build(:rate_limits),
        user: { "id" => "user_123" },
        workflow: build(:workflow)
      )
    end

    describe "#id" do
      it "is readable and writable" do
        expect(response.id).to eq("sess_accessor_test")
        response.id = "sess_new_id"
        expect(response.id).to eq("sess_new_id")
      end
    end

    describe "#object" do
      it "is readable and writable" do
        expect(response.object).to eq("session")
        response.object = "custom_session"
        expect(response.object).to eq("custom_session")
      end
    end

    describe "#status" do
      it "is readable and writable" do
        expect(response.status).to eq("active")
        response.status = "expired"
        expect(response.status).to eq("expired")
      end
    end

    describe "#client_secret" do
      it "is readable and writable" do
        expect(response.client_secret).to eq("sk_secret")
        response.client_secret = "sk_new_secret"
        expect(response.client_secret).to eq("sk_new_secret")
      end
    end

    describe "#expires_at" do
      it "is readable and writable" do
        expect(response.expires_at).to eq("2025-12-01T00:00:00Z")
        response.expires_at = "2026-01-01T00:00:00Z"
        expect(response.expires_at).to eq("2026-01-01T00:00:00Z")
      end
    end

    describe "#max_requests_per_1_minute" do
      it "is readable and writable" do
        expect(response.max_requests_per_1_minute).to eq(60)
        response.max_requests_per_1_minute = 120
        expect(response.max_requests_per_1_minute).to eq(120)
      end
    end

    describe "#user" do
      it "is readable and writable" do
        new_user = { "id" => "user_new", "name" => "New User" }
        response.user = new_user
        expect(response.user).to eq(new_user)
      end
    end

    describe "#chatkit_configuration" do
      it "is readable and writable" do
        new_config = build(:chatkit_configuration, :all_enabled)
        response.chatkit_configuration = new_config
        expect(response.chatkit_configuration).to eq(new_config)
      end
    end

    describe "#rate_limits" do
      it "is readable and writable" do
        new_limits = build(:rate_limits, :high_limit)
        response.rate_limits = new_limits
        expect(response.rate_limits).to eq(new_limits)
      end
    end

    describe "#workflow" do
      it "is readable and writable" do
        new_workflow = build(:workflow, :with_complex_state)
        response.workflow = new_workflow
        expect(response.workflow).to eq(new_workflow)
      end
    end
  end

  describe ".deserialize" do
    context "when data contains all required fields" do
      it "creates a response instance with all fields populated" do
        data = sample_response_data
        response = described_class.deserialize(data)

        expect(response).to be_a(described_class)
        expect(response.id).to eq("sess_abc123")
        expect(response.object).to eq("session")
        expect(response.status).to eq("active")
        expect(response.client_secret).to eq("sk_test_secret_123")
        expect(response.expires_at).to eq("2025-12-01T00:00:00Z")
        expect(response.max_requests_per_1_minute).to eq(60)
        expect(response.user).to eq(data["user"])
      end

      it "properly deserializes nested objects" do
        data = sample_response_data
        response = described_class.deserialize(data)

        expect(response.chatkit_configuration).to be_a(ChatKit::Session::ChatKitConfiguration)
        expect(response.chatkit_configuration.automatic_thread_titling.enabled).to be(true)
        expect(response.chatkit_configuration.file_upload.enabled).to be(false)
        expect(response.chatkit_configuration.history.enabled).to be(true)

        expect(response.rate_limits).to be_a(ChatKit::Session::RateLimits)
        expect(response.rate_limits.max_requests_per_1_minute).to eq(100)

        expect(response.workflow).to be_a(ChatKit::Session::Workflow)
        expect(response.workflow.id).to eq("wf_workflow123")
        expect(response.workflow.version).to eq("1.0.0")
      end
    end

    context "when data contains nil nested objects" do
      it "handles nil nested data gracefully" do
        data = sample_response_data.merge(
          "chatkit_configuration" => nil,
          "rate_limits" => nil,
          "workflow" => nil
        )
        response = described_class.deserialize(data)

        expect(response.chatkit_configuration).to be_a(ChatKit::Session::ChatKitConfiguration)
        expect(response.chatkit_configuration.automatic_thread_titling.enabled).to be_nil
        expect(response.rate_limits).to be_a(ChatKit::Session::RateLimits)
        expect(response.workflow).to be_a(ChatKit::Session::Workflow)
      end
    end

    context "when data contains partial nested objects" do
      it "handles partial nested configurations" do
        data = sample_response_data
        data["chatkit_configuration"] = { "automatic_thread_titling" => { "enabled" => false } }
        data["rate_limits"] = { "max_requests_per_1_minute" => 50 }
        data["workflow"] = { "id" => "wf_partial" }

        response = described_class.deserialize(data)

        expect(response.chatkit_configuration.automatic_thread_titling.enabled).to be(false)
        expect(response.chatkit_configuration.file_upload.enabled).to be_nil
        expect(response.rate_limits.max_requests_per_1_minute).to eq(50)
        expect(response.workflow.id).to eq("wf_partial")
        expect(response.workflow.version).to be_nil
      end
    end

    context "with edge cases" do
      it "handles empty user data" do
        data = sample_response_data
        data["user"] = {}
        response = described_class.deserialize(data)

        expect(response.user).to eq({})
      end

      it "handles nil user data" do
        data = sample_response_data
        data["user"] = nil
        response = described_class.deserialize(data)

        expect(response.user).to be_nil
      end

      it "handles zero values for numeric fields" do
        data = sample_response_data
        data["max_requests_per_1_minute"] = 0
        response = described_class.deserialize(data)

        expect(response.max_requests_per_1_minute).to eq(0)
      end

      it "handles complex user data structures" do
        data = sample_response_data
        data["user"] = {
          "id" => "user_complex",
          "profile" => {
            "name" => "Complex User",
            "settings" => { "theme" => "dark", "notifications" => true },
          },
          "roles" => %w[admin user],
        }
        response = described_class.deserialize(data)

        expect(response.user["profile"]["name"]).to eq("Complex User")
        expect(response.user["roles"]).to contain_exactly("admin", "user")
      end

      it "returns a new instance each time" do
        data = sample_response_data
        response1 = described_class.deserialize(data)
        response2 = described_class.deserialize(data)

        expect(response1).not_to be(response2)
        expect(response1.id).to eq(response2.id)
        expect(response1.chatkit_configuration).not_to be(response2.chatkit_configuration)
      end
    end
  end

  describe "#serialize" do
    context "when all fields have values" do
      it "returns a hash with all fields" do
        response = described_class.new(
          id: "sess_serialize_test",
          object: "session",
          status: "active",
          chatkit_configuration: build(:chatkit_configuration, :all_enabled),
          client_secret: "sk_serialize_secret",
          expires_at: "2025-12-01T00:00:00Z",
          max_requests_per_1_minute: 100,
          rate_limits: build(:rate_limits),
          user: { "id" => "user_serialize", "name" => "Serialize User" },
          workflow: build(:workflow)
        )

        result = response.serialize

        expect(result).to have_key(:id)
        expect(result).to have_key(:object)
        expect(result).to have_key(:status)
        expect(result).to have_key(:chatkit_configuration)
        expect(result).to have_key(:client_secret)
        expect(result).to have_key(:expires_at)
        expect(result).to have_key(:max_requests_per_1_minute)
        expect(result).to have_key(:rate_limits)
        expect(result).to have_key(:user)
        expect(result).to have_key(:workflow)

        expect(result[:id]).to eq("sess_serialize_test")
        expect(result[:object]).to eq("session")
        expect(result[:status]).to eq("active")
        expect(result[:client_secret]).to eq("sk_serialize_secret")
        expect(result[:expires_at]).to eq("2025-12-01T00:00:00Z")
        expect(result[:max_requests_per_1_minute]).to eq(100)
        expect(result[:user]).to eq({ "id" => "user_serialize", "name" => "Serialize User" })
      end

      it "properly serializes nested objects" do
        chatkit_config = build(:chatkit_configuration, :mixed_settings)
        rate_limits = build(:rate_limits, :low_limit)
        workflow = build(:workflow, :with_complex_state)

        response = described_class.new(
          id: "sess_nested_test",
          object: "session",
          status: "active",
          chatkit_configuration: chatkit_config,
          client_secret: "sk_secret",
          expires_at: "2025-12-01T00:00:00Z",
          max_requests_per_1_minute: 60,
          rate_limits:,
          user: { "id" => "user_nested" },
          workflow:
        )

        result = response.serialize

        expect(result[:chatkit_configuration]).to be_a(Hash)
        expect(result[:chatkit_configuration]).to have_key(:automatic_thread_titling)
        expect(result[:rate_limits]).to be_a(Hash)
        expect(result[:workflow]).to be_a(Hash)
        expect(result[:workflow]).to have_key(:id)
      end
    end

    context "when nested objects have nil values" do
      it "includes serialized nested objects even with nil values" do
        response = described_class.new(
          id: "sess_nil_test",
          object: "session",
          status: "active",
          chatkit_configuration: build(:chatkit_configuration, :minimal_config),
          client_secret: "sk_secret",
          expires_at: "2025-12-01T00:00:00Z",
          max_requests_per_1_minute: 60,
          rate_limits: build(:rate_limits, :low_limit),
          user: nil,
          workflow: build(:workflow, :minimal)
        )

        result = response.serialize

        expect(result[:user]).to be_nil
        expect(result[:chatkit_configuration]).to be_a(Hash) # Even with nil values, nested objects serialize to hashes
        expect(result[:rate_limits]).to be_a(Hash)
        expect(result[:workflow]).to be_a(Hash)
      end
    end
  end

  describe "round-trip serialization" do
    it "can deserialize what was serialized" do
      original_data = sample_response_data
      response = described_class.deserialize(original_data)
      serialized = response.serialize
      # Convert keys to strings to simulate JSON parsing
      string_keyed_data = deep_stringify_keys(serialized)
      deserialized = described_class.deserialize(string_keyed_data)

      expect(deserialized.id).to eq(response.id)
      expect(deserialized.object).to eq(response.object)
      expect(deserialized.status).to eq(response.status)
      expect(deserialized.client_secret).to eq(response.client_secret)
      expect(deserialized.expires_at).to eq(response.expires_at)
      expect(deserialized.max_requests_per_1_minute).to eq(response.max_requests_per_1_minute)
      expect(deserialized.user).to eq(response.user)
      expect(deserialized.chatkit_configuration.automatic_thread_titling.enabled).to eq(
        response.chatkit_configuration.automatic_thread_titling.enabled
      )
    end

    it "maintains data integrity through multiple round-trips" do
      original_data = sample_response_data

      # First round-trip
      response1 = described_class.deserialize(original_data)
      serialized1 = deep_stringify_keys(response1.serialize)

      # Second round-trip
      response2 = described_class.deserialize(serialized1)
      serialized2 = deep_stringify_keys(response2.serialize)

      expect(serialized1["id"]).to eq(serialized2["id"])
      expect(serialized1["status"]).to eq(serialized2["status"])
      expect(serialized1["user"]).to eq(serialized2["user"])
      expect(serialized1["chatkit_configuration"]["automatic_thread_titling"]).to eq(
        serialized2["chatkit_configuration"]["automatic_thread_titling"]
      )
    end

    # Helper method for deep key conversion
    def deep_stringify_keys(hash)
      case hash
      when Hash
        hash.each_with_object({}) do |(key, value), result|
          result[key.to_s] = deep_stringify_keys(value)
        end
      when Array
        hash.map { |item| deep_stringify_keys(item) }
      else
        hash
      end
    end
  end

  describe "integration with other components" do
    it "works with factory-created nested objects" do
      response = described_class.new(
        id: "sess_factory_test",
        object: "session",
        status: "active",
        chatkit_configuration: build(:chatkit_configuration, :all_enabled),
        client_secret: "sk_factory_secret",
        expires_at: "2025-12-01T00:00:00Z",
        max_requests_per_1_minute: 80,
        rate_limits: build(:rate_limits, :high_limit),
        user: { "id" => "user_factory" },
        workflow: build(:workflow, :with_complex_state)
      )

      expect(response.chatkit_configuration.automatic_thread_titling.enabled).to be(true)
      expect(response.rate_limits.max_requests_per_1_minute).to be > 0
      expect(response.workflow.tracing.enabled).to be(true)
    end

    it "handles complex nested factory configurations" do
      complex_workflow = build(:workflow, :with_complex_state)
      response = described_class.new(
        id: "sess_complex_test",
        object: "session",
        status: "active",
        chatkit_configuration: build(:chatkit_configuration, :mixed_settings),
        client_secret: "sk_complex_secret",
        expires_at: "2025-12-01T00:00:00Z",
        max_requests_per_1_minute: 60,
        rate_limits: build(:rate_limits, :high_limit),
        user: { "id" => "user_complex", "metadata" => { "role" => "admin" } },
        workflow: complex_workflow
      )

      serialized = response.serialize
      expect(serialized[:workflow][:state_variables]).to be_a(Hash)
      expect(serialized[:user]["metadata"]["role"]).to eq("admin")
    end
  end
end
