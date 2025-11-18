# frozen_string_literal: true

RSpec.describe ChatKit::Session::ChatKitConfiguration::AutomaticThreadTitling do
  describe ".new" do
    context "when no arguments are provided" do
      it "initializes with default enabled value" do
        instance = described_class.new
        expect(instance.enabled).to eq(ChatKit::Session::Defaults::ENABLED)
      end
    end

    context "when enabled is provided" do
      it "initializes with the provided enabled value" do
        instance = described_class.new(enabled: false)
        expect(instance.enabled).to be(false)
      end

      it "accepts true value" do
        instance = described_class.new(enabled: true)
        expect(instance.enabled).to be(true)
      end

      it "accepts nil value" do
        instance = described_class.new(enabled: nil)
        expect(instance.enabled).to be_nil
      end
    end
  end

  describe ".build" do
    context "when no arguments are provided" do
      it "creates an instance with nil enabled value" do
        instance = described_class.build
        expect(instance.enabled).to be_nil
      end
    end

    context "when enabled is provided" do
      it "creates an instance with the provided enabled value" do
        instance = described_class.build(enabled: false)
        expect(instance.enabled).to be(false)
      end

      it "accepts true value" do
        instance = described_class.build(enabled: true)
        expect(instance.enabled).to be(true)
      end

      it "accepts nil value" do
        instance = described_class.build(enabled: nil)
        expect(instance.enabled).to be_nil
      end
    end
  end

  describe ".deserialize" do
    context "when data contains enabled key" do
      it "creates an instance with enabled true" do
        data = { "enabled" => true }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
      end

      it "creates an instance with enabled false" do
        data = { "enabled" => false }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(false)
      end

      it "creates an instance with enabled nil" do
        data = { "enabled" => nil }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
      end
    end

    context "when data does not contain enabled key" do
      it "creates an instance with nil enabled value" do
        data = {}
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
      end

      it "ignores other keys in data" do
        data = { "other_key" => "other_value", "another_key" => 123 }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
      end
    end

    context "when data contains enabled key with other keys" do
      it "only uses the enabled key and ignores others" do
        data = {
          "enabled" => true,
          "extra_field" => "ignored",
          "another_field" => 456,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
      end
    end

    context "with edge cases" do
      it "handles nil data" do
        instance = described_class.deserialize(nil)

        expect(instance.enabled).to be_nil
      end

      it "handles empty data hash" do
        data = {}
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
      end

      it "handles data with string keys" do
        data = { "enabled" => false }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(false)
      end

      it "returns a new instance each time" do
        data = { "enabled" => true }
        instance1 = described_class.deserialize(data)
        instance2 = described_class.deserialize(data)

        expect(instance1).not_to be(instance2)
        expect(instance1.enabled).to eq(instance2.enabled)
      end
    end

    context "round-trip serialization" do
      it "can deserialize what was serialized" do
        original = described_class.new(enabled: true)
        serialized = original.serialize
        # Convert keys to strings to simulate JSON parsing
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(original.enabled)
      end

      it "handles nil values in round-trip" do
        original = described_class.new(enabled: nil)
        serialized = original.serialize
        # Since serialize uses compact, nil values are removed
        # so deserializing an empty hash should give nil
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to be_nil
      end

      it "handles false values in round-trip" do
        original = described_class.new(enabled: false)
        serialized = original.serialize
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(original.enabled)
      end

      it "handles default values in round-trip" do
        original = described_class.new # Uses default value
        serialized = original.serialize
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(ChatKit::Session::Defaults::ENABLED)
      end
    end
  end

  describe "#enabled" do
    it "is readable" do
      instance = described_class.new(enabled: false)
      expect(instance.enabled).to be(false)
    end

    it "is writable" do
      instance = described_class.new(enabled: true)
      instance.enabled = false
      expect(instance.enabled).to be(false)
    end
  end

  describe "#serialize" do
    context "when enabled is true" do
      it "returns a hash with enabled key" do
        instance = described_class.new(enabled: true)
        result = instance.serialize

        expect(result).to eq({ enabled: true })
      end
    end

    context "when enabled is false" do
      it "returns a hash with enabled key" do
        instance = described_class.new(enabled: false)
        result = instance.serialize

        expect(result).to eq({ enabled: false })
      end
    end

    context "when enabled is nil" do
      it "returns an empty hash due to compact" do
        instance = described_class.new(enabled: nil)
        result = instance.serialize

        expect(result).to eq({})
      end
    end

    context "when using default value" do
      it "returns a hash with the default enabled value" do
        instance = described_class.new
        result = instance.serialize

        expect(result).to eq({ enabled: ChatKit::Session::Defaults::ENABLED })
      end
    end
  end
end
