# frozen_string_literal: true

RSpec.describe ChatKit::Session::ChatKitConfiguration::FileUpload do
  describe ".new" do
    context "when no arguments are provided" do
      it "initializes with default values" do
        instance = described_class.new
        expect(instance.enabled).to eq(ChatKit::Session::Defaults::ENABLED)
        expect(instance.max_file_size).to eq(described_class::Defaults::MAX_FILE_SIZE)
        expect(instance.max_files).to eq(described_class::Defaults::MAX_FILES)
      end
    end

    context "when all arguments are provided" do
      it "initializes with the provided values" do
        instance = described_class.new(
          enabled: false,
          max_file_size: 256,
          max_files: 5
        )

        expect(instance.enabled).to be(false)
        expect(instance.max_file_size).to eq(256)
        expect(instance.max_files).to eq(5)
      end
    end

    context "when partial arguments are provided" do
      it "uses defaults for missing arguments" do
        instance = described_class.new(enabled: false)
        expect(instance.enabled).to be(false)
        expect(instance.max_file_size).to eq(described_class::Defaults::MAX_FILE_SIZE)
        expect(instance.max_files).to eq(described_class::Defaults::MAX_FILES)
      end
    end

    context "when nil values are provided" do
      it "accepts nil values" do
        instance = described_class.new(
          enabled: nil,
          max_file_size: nil,
          max_files: nil
        )

        expect(instance.enabled).to be_nil
        expect(instance.max_file_size).to be_nil
        expect(instance.max_files).to be_nil
      end
    end
  end

  describe ".build" do
    it "creates an instance with provided values" do
      instance = described_class.build(
        enabled: false,
        max_file_size: 128,
        max_files: 3
      )

      expect(instance.enabled).to be(false)
      expect(instance.max_file_size).to eq(128)
      expect(instance.max_files).to eq(3)
    end

    it "uses nil for missing parameters" do
      instance = described_class.build(
        max_file_size: 128,
        max_files: 3
      )

      expect(instance.enabled).to be_nil
      expect(instance.max_file_size).to eq(128)
      expect(instance.max_files).to eq(3)
    end

    it "creates instance with all nil values when no arguments provided" do
      instance = described_class.build

      expect(instance.enabled).to be_nil
      expect(instance.max_file_size).to be_nil
      expect(instance.max_files).to be_nil
    end
  end

  describe ".deserialize" do
    context "when data contains all keys" do
      it "creates an instance with all provided values" do
        data = {
          "enabled" => true,
          "max_file_size" => 256,
          "max_files" => 15,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.max_file_size).to eq(256)
        expect(instance.max_files).to eq(15)
      end

      it "handles false and zero values correctly" do
        data = {
          "enabled" => false,
          "max_file_size" => 0,
          "max_files" => 0,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(false)
        expect(instance.max_file_size).to eq(0)
        expect(instance.max_files).to eq(0)
      end

      it "handles nil values in data" do
        data = {
          "enabled" => nil,
          "max_file_size" => nil,
          "max_files" => nil,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
        expect(instance.max_file_size).to be_nil
        expect(instance.max_files).to be_nil
      end
    end

    context "when data contains partial keys" do
      it "handles missing enabled key" do
        data = {
          "max_file_size" => 128,
          "max_files" => 5,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
        expect(instance.max_file_size).to eq(128)
        expect(instance.max_files).to eq(5)
      end

      it "handles missing max_file_size key" do
        data = {
          "enabled" => true,
          "max_files" => 20,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.max_file_size).to be_nil
        expect(instance.max_files).to eq(20)
      end

      it "handles missing max_files key" do
        data = {
          "enabled" => false,
          "max_file_size" => 1024,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(false)
        expect(instance.max_file_size).to eq(1024)
        expect(instance.max_files).to be_nil
      end

      it "handles only one key present" do
        data = { "enabled" => true }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.max_file_size).to be_nil
        expect(instance.max_files).to be_nil
      end
    end

    context "when data does not contain relevant keys" do
      it "creates an instance with all nil values for empty data" do
        data = {}
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
        expect(instance.max_file_size).to be_nil
        expect(instance.max_files).to be_nil
      end

      it "ignores unknown keys in data" do
        data = {
          "unknown_key" => "value",
          "another_key" => 123,
          "random_field" => true,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be_nil
        expect(instance.max_file_size).to be_nil
        expect(instance.max_files).to be_nil
      end

      it "uses relevant keys and ignores unknown ones" do
        data = {
          "enabled" => true,
          "max_file_size" => 512,
          "unknown_field" => "ignored",
          "max_files" => 8,
          "extra_data" => { "nested" => "value" },
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.max_file_size).to eq(512)
        expect(instance.max_files).to eq(8)
      end
    end

    context "with edge cases" do
      it "handles nil data" do
        instance = described_class.deserialize(nil)

        expect(instance.enabled).to be_nil
        expect(instance.max_file_size).to be_nil
        expect(instance.max_files).to be_nil
      end

      it "handles data with string keys" do
        data = {
          "enabled" => false,
          "max_file_size" => 256,
          "max_files" => 12,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(false)
        expect(instance.max_file_size).to eq(256)
        expect(instance.max_files).to eq(12)
      end

      it "returns a new instance each time" do
        data = {
          "enabled" => true,
          "max_file_size" => 128,
          "max_files" => 5,
        }
        instance1 = described_class.deserialize(data)
        instance2 = described_class.deserialize(data)

        expect(instance1).not_to be(instance2)
        expect(instance1.enabled).to eq(instance2.enabled)
        expect(instance1.max_file_size).to eq(instance2.max_file_size)
        expect(instance1.max_files).to eq(instance2.max_files)
      end

      it "handles large numeric values" do
        data = {
          "enabled" => true,
          "max_file_size" => 99_999,
          "max_files" => 1_000_000,
        }
        instance = described_class.deserialize(data)

        expect(instance.enabled).to be(true)
        expect(instance.max_file_size).to eq(99_999)
        expect(instance.max_files).to eq(1_000_000)
      end
    end

    context "round-trip serialization" do
      it "can deserialize what was serialized" do
        original = described_class.new(
          enabled: true,
          max_file_size: 256,
          max_files: 7
        )
        serialized = original.serialize
        # Convert keys to strings to simulate JSON parsing
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(original.enabled)
        expect(deserialized.max_file_size).to eq(original.max_file_size)
        expect(deserialized.max_files).to eq(original.max_files)
      end

      it "handles nil values in round-trip" do
        original = described_class.new(
          enabled: nil,
          max_file_size: nil,
          max_files: nil
        )
        serialized = original.serialize
        # Since serialize uses compact, nil values are removed
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to be_nil
        expect(deserialized.max_file_size).to be_nil
        expect(deserialized.max_files).to be_nil
      end

      it "handles partial nil values in round-trip" do
        original = described_class.new(
          enabled: false,
          max_file_size: nil,
          max_files: 15
        )
        serialized = original.serialize
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(original.enabled)
        expect(deserialized.max_file_size).to be_nil # Was nil, remains nil
        expect(deserialized.max_files).to eq(original.max_files)
      end

      it "handles default values in round-trip" do
        original = described_class.new # Uses default values
        serialized = original.serialize
        string_keyed_data = serialized.transform_keys(&:to_s)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.enabled).to eq(ChatKit::Session::Defaults::ENABLED)
        expect(deserialized.max_file_size).to eq(described_class::Defaults::MAX_FILE_SIZE)
        expect(deserialized.max_files).to eq(described_class::Defaults::MAX_FILES)
      end

      it "maintains data integrity through multiple round-trips" do
        original_data = {
          "enabled" => false,
          "max_file_size" => 1024,
          "max_files" => 25,
        }

        # First round-trip
        instance1 = described_class.deserialize(original_data)
        serialized1 = instance1.serialize.transform_keys(&:to_s)

        # Second round-trip
        instance2 = described_class.deserialize(serialized1)
        serialized2 = instance2.serialize.transform_keys(&:to_s)

        expect(serialized1).to eq(serialized2)
        expect(instance2.enabled).to eq(original_data["enabled"])
        expect(instance2.max_file_size).to eq(original_data["max_file_size"])
        expect(instance2.max_files).to eq(original_data["max_files"])
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
    end

    describe "#max_file_size" do
      it "is readable and writable" do
        instance.max_file_size = 1024
        expect(instance.max_file_size).to eq(1024)
      end
    end

    describe "#max_files" do
      it "is readable and writable" do
        instance.max_files = 20
        expect(instance.max_files).to eq(20)
      end
    end
  end

  describe "#serialize" do
    context "when all values are present" do
      it "returns a hash with all keys" do
        instance = described_class.new(
          enabled: true,
          max_file_size: 256,
          max_files: 8
        )
        result = instance.serialize

        expect(result).to eq({
          enabled: true,
          max_file_size: 256,
          max_files: 8,
        })
      end
    end

    context "when some values are nil" do
      it "returns a hash without nil values due to compact" do
        instance = described_class.new(
          enabled: nil,
          max_file_size: 256,
          max_files: nil
        )
        result = instance.serialize

        expect(result).to eq({ max_file_size: 256 })
      end
    end

    context "when all values are nil" do
      it "returns an empty hash due to compact" do
        instance = described_class.new(
          enabled: nil,
          max_file_size: nil,
          max_files: nil
        )
        result = instance.serialize

        expect(result).to eq({})
      end
    end

    context "when using default values" do
      it "returns a hash with default values" do
        instance = described_class.new
        result = instance.serialize

        expect(result).to eq({
          enabled: ChatKit::Session::Defaults::ENABLED,
          max_file_size: described_class::Defaults::MAX_FILE_SIZE,
          max_files: described_class::Defaults::MAX_FILES,
        })
      end
    end
  end

  describe "::Defaults" do
    it "defines MAX_FILE_SIZE constant" do
      expect(described_class::Defaults::MAX_FILE_SIZE).to eq(512)
    end

    it "defines MAX_FILES constant" do
      expect(described_class::Defaults::MAX_FILES).to eq(10)
    end
  end
end
