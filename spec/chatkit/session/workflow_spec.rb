# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChatKit::Session::Workflow do
  describe ".new" do
    context "when only id is provided" do
      it "initializes with required id parameter" do
        workflow = described_class.new(id: "wf_test123")

        expect(workflow.id).to eq("wf_test123")
        expect(workflow.state_variables).to be_nil
        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.version).to be_nil
      end
    end

    context "when all parameters are provided" do
      let(:state_vars) { { "key1" => "value1", "key2" => "value2" } }
      let(:tracing_params) { { enabled: true } }

      it "initializes with all provided values" do
        workflow = described_class.new(
          id: "wf_full123",
          state_variables: state_vars,
          tracing: tracing_params,
          version: "2.0.0"
        )

        expect(workflow.id).to eq("wf_full123")
        expect(workflow.state_variables).to eq(state_vars)
        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.tracing.enabled).to be(true)
        expect(workflow.version).to eq("2.0.0")
      end
    end

    context "when tracing parameter is nil" do
      it "creates tracing object from empty hash" do
        workflow = described_class.new(id: "wf_nil_tracing", tracing: nil)

        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.tracing.enabled).to be_nil
      end
    end

    context "when tracing parameter is empty hash" do
      it "creates tracing object with default values" do
        workflow = described_class.new(id: "wf_empty_tracing", tracing: {})

        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.tracing.enabled).to be_nil
      end
    end

    context "when state_variables is complex nested hash" do
      let(:complex_state) do
        {
          "config" => { "timeout" => 30, "retries" => 3 },
          "user_data" => %w[item1 item2],
          "flags" => { "debug" => true, "verbose" => false },
        }
      end

      it "preserves complex state structure" do
        workflow = described_class.new(id: "wf_complex", state_variables: complex_state)

        expect(workflow.state_variables).to eq(complex_state)
        expect(workflow.state_variables["config"]["timeout"]).to eq(30)
        expect(workflow.state_variables["user_data"]).to contain_exactly("item1", "item2")
      end
    end
  end

  describe ".build" do
    context "when no parameters provided except id" do
      it "creates instance with nil optional values" do
        workflow = described_class.build(id: "wf_build_minimal")

        expect(workflow.id).to eq("wf_build_minimal")
        expect(workflow.state_variables).to be_nil
        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.version).to be_nil
      end
    end

    context "when all parameters are provided" do
      let(:state_vars) { { "build_key" => "build_value" } }
      let(:tracing_params) { { enabled: false } }

      it "creates instance with all provided values" do
        workflow = described_class.build(
          id: "wf_build_full",
          state_variables: state_vars,
          tracing: tracing_params,
          version: "1.5.0"
        )

        expect(workflow.id).to eq("wf_build_full")
        expect(workflow.state_variables).to eq(state_vars)
        expect(workflow.tracing.enabled).to be(false)
        expect(workflow.version).to eq("1.5.0")
      end
    end
  end

  describe ".deserialize" do
    context "when data contains all required fields" do
      it "creates an instance with id only" do
        data = { "id" => "wf_deserialize_minimal" }
        workflow = described_class.deserialize(data)

        expect(workflow.id).to eq("wf_deserialize_minimal")
        expect(workflow.state_variables).to be_nil
        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.tracing.enabled).to be_nil
        expect(workflow.version).to be_nil
      end

      it "creates an instance with all fields populated" do
        data = {
          "id" => "wf_deserialize_full",
          "state_variables" => { "key1" => "value1", "key2" => "value2" },
          "tracing" => { "enabled" => true },
          "version" => "2.5.0",
        }
        workflow = described_class.deserialize(data)

        expect(workflow.id).to eq("wf_deserialize_full")
        expect(workflow.state_variables).to eq({ "key1" => "value1", "key2" => "value2" })
        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.tracing.enabled).to be(true)
        expect(workflow.version).to eq("2.5.0")
      end
    end

    context "when data contains partial fields" do
      it "handles missing state_variables" do
        data = {
          "id" => "wf_no_state",
          "tracing" => { "enabled" => false },
          "version" => "1.0.0",
        }
        workflow = described_class.deserialize(data)

        expect(workflow.id).to eq("wf_no_state")
        expect(workflow.state_variables).to be_nil
        expect(workflow.tracing.enabled).to be(false)
        expect(workflow.version).to eq("1.0.0")
      end

      it "handles missing tracing field" do
        data = {
          "id" => "wf_no_tracing",
          "state_variables" => { "test" => "value" },
          "version" => "3.0.0",
        }
        workflow = described_class.deserialize(data)

        expect(workflow.id).to eq("wf_no_tracing")
        expect(workflow.state_variables).to eq({ "test" => "value" })
        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.tracing.enabled).to be_nil
        expect(workflow.version).to eq("3.0.0")
      end

      it "handles missing version field" do
        data = {
          "id" => "wf_no_version",
          "state_variables" => { "config" => { "timeout" => 30 } },
          "tracing" => { "enabled" => true },
        }
        workflow = described_class.deserialize(data)

        expect(workflow.id).to eq("wf_no_version")
        expect(workflow.state_variables).to eq({ "config" => { "timeout" => 30 } })
        expect(workflow.tracing.enabled).to be(true)
        expect(workflow.version).to be_nil
      end
    end

    context "when tracing data has various values" do
      it "handles tracing with enabled true" do
        data = {
          "id" => "wf_tracing_true",
          "tracing" => { "enabled" => true },
        }
        workflow = described_class.deserialize(data)

        expect(workflow.tracing.enabled).to be(true)
      end

      it "handles tracing with enabled false" do
        data = {
          "id" => "wf_tracing_false",
          "tracing" => { "enabled" => false },
        }
        workflow = described_class.deserialize(data)

        expect(workflow.tracing.enabled).to be(false)
      end

      it "handles tracing with enabled nil" do
        data = {
          "id" => "wf_tracing_nil",
          "tracing" => { "enabled" => nil },
        }
        workflow = described_class.deserialize(data)

        expect(workflow.tracing.enabled).to be_nil
      end

      it "handles empty tracing data" do
        data = {
          "id" => "wf_empty_tracing",
          "tracing" => {},
        }
        workflow = described_class.deserialize(data)

        expect(workflow.tracing.enabled).to be_nil
      end
    end

    context "when state_variables contains complex data" do
      it "preserves nested hash structures" do
        complex_state = {
          "config" => { "timeout" => 30, "retries" => 3 },
          "user_preferences" => { "theme" => "dark", "language" => "en" },
          "feature_flags" => { "new_ui" => true, "beta_features" => false },
          "metadata" => { "created_at" => "2023-01-01", "tags" => %w[important urgent] },
        }
        data = {
          "id" => "wf_complex_state",
          "state_variables" => complex_state,
        }
        workflow = described_class.deserialize(data)

        expect(workflow.state_variables).to eq(complex_state)
        expect(workflow.state_variables["config"]["timeout"]).to eq(30)
        expect(workflow.state_variables["metadata"]["tags"]).to contain_exactly("important", "urgent")
      end

      it "handles state_variables as empty hash" do
        data = {
          "id" => "wf_empty_state",
          "state_variables" => {},
        }
        workflow = described_class.deserialize(data)

        expect(workflow.state_variables).to eq({})
      end
    end

    context "with edge cases" do
      it "ignores extra fields in data" do
        data = {
          "id" => "wf_extra_fields",
          "state_variables" => { "key" => "value" },
          "tracing" => { "enabled" => true },
          "version" => "1.0.0",
          "extra_field" => "should_be_ignored",
          "another_field" => 123,
        }
        workflow = described_class.deserialize(data)

        expect(workflow.id).to eq("wf_extra_fields")
        expect(workflow.state_variables).to eq({ "key" => "value" })
        expect(workflow.tracing.enabled).to be(true)
        expect(workflow.version).to eq("1.0.0")
      end

      it "returns a new instance each time" do
        data = { "id" => "wf_new_instance", "version" => "1.0.0" }
        workflow1 = described_class.deserialize(data)
        workflow2 = described_class.deserialize(data)

        expect(workflow1).not_to be(workflow2)
        expect(workflow1.id).to eq(workflow2.id)
        expect(workflow1.version).to eq(workflow2.version)
      end

      it "handles string values properly" do
        data = {
          "id" => "wf_string_handling",
          "version" => "2.0.0-alpha.1+build.456",
        }
        workflow = described_class.deserialize(data)

        expect(workflow.id).to eq("wf_string_handling")
        expect(workflow.version).to eq("2.0.0-alpha.1+build.456")
      end
    end

    context "round-trip serialization" do
      it "can deserialize what was serialized" do
        original = described_class.new(
          id: "wf_roundtrip",
          state_variables: { "test" => "value", "number" => 42 },
          tracing: { enabled: true },
          version: "1.2.3"
        )
        serialized = original.serialize
        # Convert keys to strings to simulate JSON parsing
        string_keyed_data = serialized.transform_keys(&:to_s)
        # Also convert the nested tracing keys
        string_keyed_data["tracing"] = string_keyed_data["tracing"].transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.id).to eq(original.id)
        expect(deserialized.state_variables).to eq(original.state_variables)
        expect(deserialized.tracing.enabled).to eq(original.tracing.enabled)
        expect(deserialized.version).to eq(original.version)
      end

      it "handles nil values in round-trip" do
        original = described_class.new(
          id: "wf_nil_roundtrip",
          state_variables: nil,
          tracing: { enabled: nil },
          version: nil
        )
        serialized = original.serialize
        # Since serialize uses compact, nil values are removed
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.id).to eq(original.id)
        expect(deserialized.state_variables).to be_nil
        expect(deserialized.tracing.enabled).to be_nil
        expect(deserialized.version).to be_nil
      end

      it "maintains data integrity through multiple round-trips" do
        original_data = {
          "id" => "wf_multi_roundtrip",
          "state_variables" => { "counter" => 5, "active" => true },
          "tracing" => { "enabled" => false },
          "version" => "0.1.0",
        }

        # First round-trip
        workflow1 = described_class.deserialize(original_data)
        serialized1 = workflow1.serialize.transform_keys(&:to_s)
        serialized1["tracing"] = serialized1["tracing"].transform_keys(&:to_s)

        # Second round-trip
        workflow2 = described_class.deserialize(serialized1)
        serialized2 = workflow2.serialize.transform_keys(&:to_s)
        serialized2["tracing"] = serialized2["tracing"].transform_keys(&:to_s)

        expect(serialized1).to eq(serialized2)
        expect(workflow2.id).to eq(original_data["id"])
        expect(workflow2.state_variables).to eq(original_data["state_variables"])
        expect(workflow2.version).to eq(original_data["version"])
      end
    end
  end

  describe "attribute accessors" do
    let(:workflow) { described_class.new(id: "wf_accessor_test") }

    describe "#id" do
      it "is readable and writable" do
        expect(workflow.id).to eq("wf_accessor_test")
        workflow.id = "wf_new_id"
        expect(workflow.id).to eq("wf_new_id")
      end
    end

    describe "#state_variables" do
      it "is readable and writable" do
        expect(workflow.state_variables).to be_nil
        new_state = { "test" => "value" }
        workflow.state_variables = new_state
        expect(workflow.state_variables).to eq(new_state)
      end

      it "accepts nil value" do
        workflow.state_variables = nil
        expect(workflow.state_variables).to be_nil
      end
    end

    describe "#tracing" do
      it "is readable and writable" do
        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        new_tracing = ChatKit::Session::Workflow::Tracing.new(enabled: false)
        workflow.tracing = new_tracing
        expect(workflow.tracing).to eq(new_tracing)
        expect(workflow.tracing.enabled).to be(false)
      end
    end

    describe "#version" do
      it "is readable and writable" do
        expect(workflow.version).to be_nil
        workflow.version = "3.0.0"
        expect(workflow.version).to eq("3.0.0")
      end

      it "accepts nil value" do
        workflow.version = nil
        expect(workflow.version).to be_nil
      end
    end
  end

  describe "#serialize" do
    context "when all attributes have values" do
      let(:state_vars) { { "serialize_key" => "serialize_value" } }
      let(:tracing_params) { { enabled: true } }
      let(:workflow) do
        described_class.new(
          id: "wf_serialize_full",
          state_variables: state_vars,
          tracing: tracing_params,
          version: "2.1.0"
        )
      end

      it "returns hash with all attributes" do
        result = workflow.serialize

        expect(result).to eq({
          id: "wf_serialize_full",
          state_variables: state_vars,
          tracing: { enabled: true },
          version: "2.1.0",
        })
      end
    end

    context "when optional attributes are nil" do
      let(:workflow) { described_class.new(id: "wf_serialize_minimal") }

      it "excludes nil values due to compact" do
        result = workflow.serialize

        expect(result).to eq({
          id: "wf_serialize_minimal",
          tracing: {},
        })
        expect(result).not_to have_key(:state_variables)
        expect(result).not_to have_key(:version)
      end
    end

    context "when state_variables is empty hash" do
      let(:workflow) do
        described_class.new(
          id: "wf_empty_state",
          state_variables: {},
          version: "1.0.0"
        )
      end

      it "includes empty hash in serialization" do
        result = workflow.serialize

        expect(result[:state_variables]).to eq({})
        expect(result).to have_key(:state_variables)
      end
    end

    context "when tracing is disabled" do
      let(:workflow) do
        described_class.new(
          id: "wf_disabled_tracing",
          tracing: { enabled: false }
        )
      end

      it "includes tracing with enabled: false" do
        result = workflow.serialize

        expect(result[:tracing]).to eq({ enabled: false })
      end
    end

    context "when tracing enabled is nil" do
      let(:workflow) do
        described_class.new(
          id: "wf_nil_tracing_enabled",
          tracing: { enabled: nil }
        )
      end

      it "excludes enabled from tracing due to compact" do
        result = workflow.serialize

        expect(result[:tracing]).to eq({})
      end
    end
  end

  describe "integration with Tracing" do
    context "when tracing parameter is provided as hash" do
      it "converts hash to Tracing object" do
        workflow = described_class.new(
          id: "wf_tracing_integration",
          tracing: { enabled: true }
        )

        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.tracing.enabled).to be(true)
      end
    end

    context "when tracing parameter responds to to_h" do
      it "converts to hash and creates tracing object" do
        custom_tracing = Struct.new(:enabled) do
          def to_h
            { enabled: }
          end
        end.new(false)

        workflow = described_class.new(
          id: "wf_custom_tracing",
          tracing: custom_tracing
        )

        expect(workflow.tracing).to be_a(ChatKit::Session::Workflow::Tracing)
        expect(workflow.tracing.enabled).to be(false)
      end
    end
  end

  describe "edge cases and validation" do
    context "with boundary values" do
      it "handles empty string id" do
        workflow = described_class.new(id: "")
        expect(workflow.id).to eq("")
      end

      it "handles very long id" do
        long_id = "wf_#{'x' * 1000}"
        workflow = described_class.new(id: long_id)
        expect(workflow.id).to eq(long_id)
      end

      it "handles version with special characters" do
        workflow = described_class.new(id: "wf_test", version: "1.0.0-beta.1+build.123")
        expect(workflow.version).to eq("1.0.0-beta.1+build.123")
      end
    end

    context "when comparing new vs build methods" do
      it "produces identical results when same parameters provided" do
        params = {
          id: "wf_comparison",
          state_variables: { "key" => "value" },
          tracing: { enabled: true },
          version: "1.0.0",
        }

        workflow_new = described_class.new(**params)
        workflow_build = described_class.build(**params)

        expect(workflow_new.serialize).to eq(workflow_build.serialize)
      end
    end

    context "when checking serialization consistency" do
      it "maintains consistent serialization across multiple calls" do
        workflow = described_class.new(
          id: "wf_consistency",
          state_variables: { "test" => "value" },
          version: "1.0.0"
        )

        first_serialize = workflow.serialize
        second_serialize = workflow.serialize

        expect(first_serialize).to eq(second_serialize)
      end

      it "reflects changes in subsequent serializations" do
        workflow = described_class.new(id: "wf_changes")

        original_serialize = workflow.serialize
        workflow.version = "2.0.0"
        updated_serialize = workflow.serialize

        expect(original_serialize).not_to have_key(:version)
        expect(updated_serialize[:version]).to eq("2.0.0")
      end
    end
  end
end
