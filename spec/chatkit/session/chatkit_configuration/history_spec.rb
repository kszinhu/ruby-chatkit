# frozen_string_literal: true

RSpec.describe ChatKit::Session::ChatKitConfiguration::History do
  describe ".new" do
    context "when no arguments are provided" do
      it "initializes with default enabled value and nil recent_threads" do
        instance = described_class.new
        expect(instance.enabled).to eq(ChatKit::Session::Defaults::ENABLED)
        expect(instance.recent_threads).to be_nil
      end
    end

    context "when all arguments are provided" do
      it "initializes with the provided values" do
        instance = described_class.new(
          enabled: false,
          recent_threads: 50
        )

        expect(instance.enabled).to be(false)
        expect(instance.recent_threads).to eq(50)
      end
    end

    context "when partial arguments are provided" do
      it "uses defaults for missing arguments" do
        instance = described_class.new(enabled: false)
        expect(instance.enabled).to be(false)
        expect(instance.recent_threads).to be_nil
      end

      it "accepts recent_threads without enabled" do
        instance = described_class.new(recent_threads: 25)
        expect(instance.enabled).to eq(ChatKit::Session::Defaults::ENABLED)
        expect(instance.recent_threads).to eq(25)
      end
    end

    context "when nil values are provided" do
      it "accepts nil values" do
        instance = described_class.new(
          enabled: nil,
          recent_threads: nil
        )

        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to be_nil
      end
    end
  end

  describe ".build" do
    context "when no arguments are provided" do
      it "creates an instance with nil values" do
        instance = described_class.build
        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to be_nil
      end
    end

    context "when all arguments are provided" do
      it "creates an instance with provided values" do
        instance = described_class.build(
          enabled: false,
          recent_threads: 100
        )

        expect(instance.enabled).to be(false)
        expect(instance.recent_threads).to eq(100)
      end
    end

    context "when partial arguments are provided" do
      it "uses nil for missing arguments" do
        instance = described_class.build(recent_threads: 75)
        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to eq(75)
      end
    end

    context "when nil values are provided" do
      it "accepts nil values" do
        instance = described_class.build(
          enabled: nil,
          recent_threads: nil
        )

        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to be_nil
      end
    end
  end

  describe ".deserialize" do
    context "when data contains all keys" do
      it "creates an instance with all provided values" do
        data = {
          "enabled" => true,
          "recent_threads" => 50,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.recent_threads).to eq(50)
      end

      it "handles false and zero values correctly" do
        data = {
          "enabled" => false,
          "recent_threads" => 0,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(false)
        expect(instance.recent_threads).to eq(0)
      end

      it "handles nil values in data" do
        data = {
          "enabled" => nil,
          "recent_threads" => nil,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to be_nil
      end
    end

    context "when data contains partial keys" do
      it "handles missing enabled key" do
        data = { "recent_threads" => 25 }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to eq(25)
      end

      it "handles missing recent_threads key" do
        data = { "enabled" => true }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.recent_threads).to be_nil
      end

      it "handles only enabled key with false value" do
        data = { "enabled" => false }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(false)
        expect(instance.recent_threads).to be_nil
      end

      it "handles only recent_threads key with zero value" do
        data = { "recent_threads" => 0 }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to eq(0)
      end
    end

    context "when data does not contain relevant keys" do
      it "creates an instance with all nil values for empty data" do
        data = {}
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to be_nil
      end

      it "ignores unknown keys in data" do
        data = {
          "unknown_key" => "value",
          "another_key" => 123,
          "random_field" => true,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to be_nil
      end

      it "uses relevant keys and ignores unknown ones" do
        data = {
          "enabled" => true,
          "recent_threads" => 30,
          "unknown_field" => "ignored",
          "extra_data" => { "nested" => "value" },
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.recent_threads).to eq(30)
      end
    end

    context "with edge cases" do
      it "handles nil data" do
        instance = described_class.deserialize(nil)

        expect(instance.enabled).to be_nil
        expect(instance.recent_threads).to be_nil
      end

      it "handles data with string keys" do
        data = {
          "enabled" => false,
          "recent_threads" => 15,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(false)
        expect(instance.recent_threads).to eq(15)
      end

      it "returns a new instance each time" do
        data = {
          "enabled" => true,
          "recent_threads" => 40,
        }
        instance1 = described_class.deserialize(data)
        instance2 = described_class.deserialize(data)

        expect(instance1).not_to be(instance2)
        expect(instance1.enabled).to eq(instance2.enabled)
        expect(instance1.recent_threads).to eq(instance2.recent_threads)
      end

      it "handles large numeric values for recent_threads" do
        data = {
          "enabled" => true,
          "recent_threads" => 999_999,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.recent_threads).to eq(999_999)
      end

      it "handles negative values for recent_threads" do
        data = {
          "enabled" => true,
          "recent_threads" => -5,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.recent_threads).to eq(-5)
      end
    end

    context "round-trip serialization" do
      it "can deserialize what was serialized" do
        original = described_class.new(
          enabled: true,
          recent_threads: 35
        )
        serialized = original.serialize
        # Convert keys to strings to simulate JSON parsing
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(original.enabled)
        expect(deserialized.recent_threads).to eq(original.recent_threads)
      end

      it "handles nil values in round-trip" do
        original = described_class.new(
          enabled: nil,
          recent_threads: nil
        )
        serialized = original.serialize
        # Since serialize uses compact, nil values are removed
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to be_nil
        expect(deserialized.recent_threads).to be_nil
      end

      it "handles partial nil values in round-trip" do
        original = described_class.new(
          enabled: false,
          recent_threads: nil
        )
        serialized = original.serialize
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(original.enabled)
        expect(deserialized.recent_threads).to be_nil # Was nil, remains nil
      end

      it "handles default values in round-trip" do
        original = described_class.new # Uses default enabled value
        serialized = original.serialize
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(ChatKit::Session::Defaults::ENABLED)
        expect(deserialized.recent_threads).to be_nil # Default is nil
      end

      it "handles zero values in round-trip" do
        original = described_class.new(
          enabled: false,
          recent_threads: 0
        )
        serialized = original.serialize
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(original.enabled)
        expect(deserialized.recent_threads).to eq(original.recent_threads)
      end

      it "maintains data integrity through multiple round-trips" do
        original_data = {
          "enabled" => false,
          "recent_threads" => 75,
        }

        # First round-trip
        instance1 = described_class.deserialize(original_data)
        serialized1 = instance1.serialize.transform_keys(&:to_s)

        # Second round-trip
        instance2 = described_class.deserialize(serialized1)
        serialized2 = instance2.serialize.transform_keys(&:to_s)

        expect(serialized1).to eq(serialized2)
        expect(instance2.enabled).to eq(original_data["enabled"])
        expect(instance2.recent_threads).to eq(original_data["recent_threads"])
      end
    end
  end

  describe "attribute accessors" do
    let(:instance) { described_class.new }

    describe "#enabled" do
      it "is readable and writable" do
        instance.enabled = false
        expect(instance.enabled).to be(false)
      end

      it "accepts boolean values" do
        instance.enabled = true
        expect(instance.enabled).to be(true)

        instance.enabled = false
        expect(instance.enabled).to be(false)
      end

      it "accepts nil value" do
        instance.enabled = nil
        expect(instance.enabled).to be_nil
      end
    end

    describe "#recent_threads" do
      it "is readable and writable" do
        instance.recent_threads = 42
        expect(instance.recent_threads).to eq(42)
      end

      it "accepts integer values" do
        instance.recent_threads = 0
        expect(instance.recent_threads).to eq(0)

        instance.recent_threads = 999
        expect(instance.recent_threads).to eq(999)
      end

      it "accepts nil value" do
        instance.recent_threads = nil
        expect(instance.recent_threads).to be_nil
      end
    end
  end

  describe "#serialize" do
    context "when all values are present" do
      it "returns a hash with all keys" do
        instance = described_class.new(
          enabled: true,
          recent_threads: 30
        )
        result = instance.serialize

        expect(result).to eq({
          enabled: true,
          recent_threads: 30,
        })
      end
    end

    context "when enabled is false" do
      it "returns a hash with enabled false" do
        instance = described_class.new(
          enabled: false,
          recent_threads: 15
        )
        result = instance.serialize

        expect(result).to eq({
          enabled: false,
          recent_threads: 15,
        })
      end
    end

    context "when some values are nil" do
      it "returns a hash without nil values due to compact" do
        instance = described_class.new(
          enabled: nil,
          recent_threads: 20
        )
        result = instance.serialize

        expect(result).to eq({ recent_threads: 20 })
      end

      it "excludes nil recent_threads" do
        instance = described_class.new(
          enabled: true,
          recent_threads: nil
        )
        result = instance.serialize

        expect(result).to eq({ enabled: true })
      end
    end

    context "when all values are nil" do
      it "returns an empty hash due to compact" do
        instance = described_class.new(
          enabled: nil,
          recent_threads: nil
        )
        result = instance.serialize

        expect(result).to eq({})
      end
    end

    context "when using default values" do
      it "returns a hash with default enabled value" do
        instance = described_class.new
        result = instance.serialize

        expect(result).to eq({
          enabled: ChatKit::Session::Defaults::ENABLED,
        })
      end

      it "excludes nil recent_threads from default initialization" do
        instance = described_class.new
        result = instance.serialize

        expect(result).not_to have_key(:recent_threads)
      end
    end

    context "when recent_threads is zero" do
      it "includes zero value in the result" do
        instance = described_class.new(
          enabled: true,
          recent_threads: 0
        )
        result = instance.serialize

        expect(result).to eq({
          enabled: true,
          recent_threads: 0,
        })
      end
    end
  end
end
