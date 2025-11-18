# frozen_string_literal: true

RSpec.describe ChatKit::Session::ChatKitConfiguration do
  describe ".new" do
    context "when all required arguments are provided" do
      it "initializes with provided configuration hashes" do
        config = described_class.new(
          file_upload: { enabled: false, max_file_size: 256, max_files: 5 },
          history: { enabled: true, recent_threads: 25 },
          automatic_thread_titling: { enabled: true }
        )

        expect(config.automatic_thread_titling).to be_a(ChatKit::Session::ChatKitConfiguration::AutomaticThreadTitling)
        expect(config.file_upload).to be_a(ChatKit::Session::ChatKitConfiguration::FileUpload)
        expect(config.history).to be_a(ChatKit::Session::ChatKitConfiguration::History)
      end

      it "properly initializes nested objects with provided values" do
        config = described_class.new(
          file_upload: { enabled: true, max_file_size: 512, max_files: 10 },
          history: { enabled: false, recent_threads: 50 },
          automatic_thread_titling: { enabled: false }
        )

        expect(config.automatic_thread_titling.enabled).to be(false)
        expect(config.file_upload.enabled).to be(true)
        expect(config.file_upload.max_file_size).to eq(512)
        expect(config.file_upload.max_files).to eq(10)
        expect(config.history.enabled).to be(false)
        expect(config.history.recent_threads).to eq(50)
      end
    end

    context "when optional automatic_thread_titling is nil" do
      it "creates AutomaticThreadTitling with nil enabled" do
        config = described_class.new(
          file_upload: { enabled: true, max_file_size: 256, max_files: 5 },
          history: { enabled: true, recent_threads: 25 },
          automatic_thread_titling: nil
        )

        expect(config.automatic_thread_titling.enabled).to be_nil
      end
    end

    context "when empty hashes are provided for all components" do
      it "uses build method defaults for all components" do
        config = described_class.new(
          file_upload: {},
          history: {},
          automatic_thread_titling: {}
        )

        # All components should have nil values when built with empty hashes
        expect(config.automatic_thread_titling.enabled).to be_nil
        expect(config.file_upload.enabled).to be_nil
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
        expect(config.history.enabled).to be_nil
        expect(config.history.recent_threads).to be_nil
      end
    end

    context "when dealing with FileUpload optional parameters" do
      it "handles FileUpload build properly with optional parameters" do
        config = described_class.new(
          file_upload: { max_file_size: 128, max_files: 3 },
          history: { enabled: true },
          automatic_thread_titling: { enabled: true }
        )

        expect(config.file_upload.enabled).to be_nil # build defaults to nil
        expect(config.file_upload.max_file_size).to eq(128)
        expect(config.file_upload.max_files).to eq(3)
      end

      it "handles FileUpload with only enabled parameter" do
        config = described_class.new(
          file_upload: { enabled: false }
        )

        expect(config.file_upload.enabled).to be(false)
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
      end
    end
  end

  describe ".build" do
    context "when no arguments are provided" do
      it "creates instance with all components having nil values" do
        config = described_class.build

        expect(config.automatic_thread_titling.enabled).to be_nil
        expect(config.file_upload.enabled).to be_nil
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
        expect(config.history.enabled).to be_nil
        expect(config.history.recent_threads).to be_nil
      end
    end

    context "when all arguments are provided" do
      it "creates instance with provided configurations" do
        config = described_class.build(
          file_upload: { enabled: false, max_file_size: 256, max_files: 8 },
          history: { enabled: true, recent_threads: 100 },
          automatic_thread_titling: { enabled: true }
        )

        expect(config.automatic_thread_titling.enabled).to be(true)
        expect(config.file_upload.enabled).to be(false)
        expect(config.file_upload.max_file_size).to eq(256)
        expect(config.file_upload.max_files).to eq(8)
        expect(config.history.enabled).to be(true)
        expect(config.history.recent_threads).to eq(100)
      end
    end

    context "when partial arguments are provided" do
      it "uses nil for missing arguments" do
        config = described_class.build(
          file_upload: { max_file_size: 128, max_files: 3 },
          automatic_thread_titling: { enabled: false }
        )

        expect(config.automatic_thread_titling.enabled).to be(false)
        expect(config.file_upload.enabled).to be_nil # build default
        expect(config.file_upload.max_file_size).to eq(128)
        expect(config.file_upload.max_files).to eq(3)
        expect(config.history.enabled).to be_nil # nil argument becomes nil values
        expect(config.history.recent_threads).to be_nil
      end

      it "can build with minimal parameters" do
        config = described_class.build(
          automatic_thread_titling: { enabled: true }
        )

        expect(config.automatic_thread_titling.enabled).to be(true)
        expect(config.file_upload.enabled).to be_nil
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
        expect(config.history.enabled).to be_nil
        expect(config.history.recent_threads).to be_nil
      end
    end
  end

  describe ".deserialize" do
    context "when data contains all component configurations" do
      it "creates instance with all components populated" do
        data = {
          "automatic_thread_titling" => { "enabled" => true },
          "file_upload" => { "enabled" => false, "max_file_size" => 256, "max_files" => 8 },
          "history" => { "enabled" => true, "recent_threads" => 50 },
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling).to be_a(ChatKit::Session::ChatKitConfiguration::AutomaticThreadTitling)
        expect(config.automatic_thread_titling.enabled).to be(true)
        expect(config.file_upload).to be_a(ChatKit::Session::ChatKitConfiguration::FileUpload)
        expect(config.file_upload.enabled).to be(false)
        expect(config.file_upload.max_file_size).to eq(256)
        expect(config.file_upload.max_files).to eq(8)
        expect(config.history).to be_a(ChatKit::Session::ChatKitConfiguration::History)
        expect(config.history.enabled).to be(true)
        expect(config.history.recent_threads).to eq(50)
      end

      it "handles false and zero values correctly" do
        data = {
          "automatic_thread_titling" => { "enabled" => false },
          "file_upload" => { "enabled" => false, "max_file_size" => 0, "max_files" => 0 },
          "history" => { "enabled" => false, "recent_threads" => 0 },
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be(false)
        expect(config.file_upload.enabled).to be(false)
        expect(config.file_upload.max_file_size).to eq(0)
        expect(config.file_upload.max_files).to eq(0)
        expect(config.history.enabled).to be(false)
        expect(config.history.recent_threads).to eq(0)
      end

      it "handles nil values in nested data" do
        data = {
          "automatic_thread_titling" => { "enabled" => nil },
          "file_upload" => { "enabled" => nil, "max_file_size" => nil, "max_files" => nil },
          "history" => { "enabled" => nil, "recent_threads" => nil },
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be_nil
        expect(config.file_upload.enabled).to be_nil
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
        expect(config.history.enabled).to be_nil
        expect(config.history.recent_threads).to be_nil
      end
    end

    context "when data contains partial component configurations" do
      it "handles missing automatic_thread_titling" do
        data = {
          "file_upload" => { "enabled" => true, "max_file_size" => 128 },
          "history" => { "enabled" => false },
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be_nil
        expect(config.file_upload.enabled).to be(true)
        expect(config.file_upload.max_file_size).to eq(128)
        expect(config.history.enabled).to be(false)
      end

      it "handles missing file_upload" do
        data = {
          "automatic_thread_titling" => { "enabled" => true },
          "history" => { "enabled" => true, "recent_threads" => 75 },
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be(true)
        expect(config.file_upload.enabled).to be_nil
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
        expect(config.history.enabled).to be(true)
        expect(config.history.recent_threads).to eq(75)
      end

      it "handles missing history" do
        data = {
          "automatic_thread_titling" => { "enabled" => false },
          "file_upload" => { "enabled" => true, "max_files" => 15 },
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be(false)
        expect(config.file_upload.enabled).to be(true)
        expect(config.file_upload.max_files).to eq(15)
        expect(config.history.enabled).to be_nil
        expect(config.history.recent_threads).to be_nil
      end

      it "handles only one component present" do
        data = {
          "automatic_thread_titling" => { "enabled" => true },
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be(true)
        expect(config.file_upload.enabled).to be_nil
        expect(config.history.enabled).to be_nil
      end
    end

    context "when data is empty or contains no relevant keys" do
      it "creates instance with all nil values for empty data" do
        data = {}
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be_nil
        expect(config.file_upload.enabled).to be_nil
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
        expect(config.history.enabled).to be_nil
        expect(config.history.recent_threads).to be_nil
      end

      it "ignores unknown keys in data" do
        data = {
          "unknown_config" => { "some" => "value" },
          "random_field" => "ignored",
          "nested_unknown" => { "deep" => { "value" => 123 } },
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be_nil
        expect(config.file_upload.enabled).to be_nil
        expect(config.history.enabled).to be_nil
      end

      it "uses relevant keys and ignores unknown ones" do
        data = {
          "automatic_thread_titling" => { "enabled" => true },
          "unknown_config" => { "ignored" => "value" },
          "file_upload" => { "enabled" => false, "max_file_size" => 512 },
          "random_field" => "also ignored",
          "history" => { "enabled" => true, "recent_threads" => 25 },
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be(true)
        expect(config.file_upload.enabled).to be(false)
        expect(config.file_upload.max_file_size).to eq(512)
        expect(config.history.enabled).to be(true)
        expect(config.history.recent_threads).to eq(25)
      end
    end

    context "with edge cases" do
      it "handles nil data" do
        config = described_class.deserialize(nil)

        expect(config.automatic_thread_titling.enabled).to be_nil
        expect(config.file_upload.enabled).to be_nil
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
        expect(config.history.enabled).to be_nil
        expect(config.history.recent_threads).to be_nil
      end

      it "handles empty nested hashes" do
        data = {
          "automatic_thread_titling" => {},
          "file_upload" => {},
          "history" => {},
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be_nil
        expect(config.file_upload.enabled).to be_nil
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
        expect(config.history.enabled).to be_nil
        expect(config.history.recent_threads).to be_nil
      end

      it "returns a new instance each time" do
        data = {
          "automatic_thread_titling" => { "enabled" => true },
          "file_upload" => { "enabled" => false },
          "history" => { "enabled" => true },
        }
        config1 = described_class.deserialize(data)
        config2 = described_class.deserialize(data)

        expect(config1).not_to be(config2)
        expect(config1.automatic_thread_titling).not_to be(config2.automatic_thread_titling)
        expect(config1.file_upload).not_to be(config2.file_upload)
        expect(config1.history).not_to be(config2.history)
        # But values should be equal
        expect(config1.automatic_thread_titling.enabled).to eq(config2.automatic_thread_titling.enabled)
      end

      it "handles partial nested data gracefully" do
        data = {
          "automatic_thread_titling" => { "enabled" => true },
          "file_upload" => { "max_file_size" => 256 }, # missing enabled and max_files
          "history" => { "recent_threads" => 100 }, # missing enabled
        }
        config = described_class.deserialize(data)

        expect(config.automatic_thread_titling.enabled).to be(true)
        expect(config.file_upload.enabled).to be_nil
        expect(config.file_upload.max_file_size).to eq(256)
        expect(config.file_upload.max_files).to be_nil
        expect(config.history.enabled).to be_nil
        expect(config.history.recent_threads).to eq(100)
      end
    end

    context "round-trip serialization" do
      it "can deserialize what was serialized" do
        original = described_class.new(
          automatic_thread_titling: { enabled: true },
          file_upload: { enabled: false, max_file_size: 256, max_files: 8 },
          history: { enabled: true, recent_threads: 50 }
        )
        serialized = original.serialize
        # Convert keys to strings to simulate JSON parsing
        string_keyed_data = deep_stringify_keys(serialized)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.automatic_thread_titling.enabled).to eq(original.automatic_thread_titling.enabled)
        expect(deserialized.file_upload.enabled).to eq(original.file_upload.enabled)
        expect(deserialized.file_upload.max_file_size).to eq(original.file_upload.max_file_size)
        expect(deserialized.file_upload.max_files).to eq(original.file_upload.max_files)
        expect(deserialized.history.enabled).to eq(original.history.enabled)
        expect(deserialized.history.recent_threads).to eq(original.history.recent_threads)
      end

      it "handles nil values in round-trip" do
        original = described_class.new(
          automatic_thread_titling: { enabled: nil },
          file_upload: { enabled: nil, max_file_size: nil, max_files: nil },
          history: { enabled: nil, recent_threads: nil }
        )
        serialized = original.serialize
        string_keyed_data = deep_stringify_keys(serialized)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.automatic_thread_titling.enabled).to be_nil
        expect(deserialized.file_upload.enabled).to be_nil
        expect(deserialized.file_upload.max_file_size).to be_nil
        expect(deserialized.file_upload.max_files).to be_nil
        expect(deserialized.history.enabled).to be_nil
        expect(deserialized.history.recent_threads).to be_nil
      end

      it "handles partial nil values in round-trip" do
        original = described_class.new(
          automatic_thread_titling: { enabled: true },
          file_upload: { enabled: false, max_file_size: nil, max_files: 5 },
          history: { enabled: nil, recent_threads: 30 }
        )
        serialized = original.serialize
        string_keyed_data = deep_stringify_keys(serialized)
        deserialized = described_class.deserialize(string_keyed_data)

        expect(deserialized.automatic_thread_titling.enabled).to be(true)
        expect(deserialized.file_upload.enabled).to be(false)
        expect(deserialized.file_upload.max_file_size).to be_nil # Was nil, remains nil
        expect(deserialized.file_upload.max_files).to eq(5)
        expect(deserialized.history.enabled).to be_nil # Was nil, remains nil
        expect(deserialized.history.recent_threads).to eq(30)
      end

      it "maintains data integrity through multiple round-trips" do
        original_data = {
          "automatic_thread_titling" => { "enabled" => false },
          "file_upload" => { "enabled" => true, "max_file_size" => 1024, "max_files" => 25 },
          "history" => { "enabled" => true, "recent_threads" => 75 },
        }

        # First round-trip
        config1 = described_class.deserialize(original_data)
        serialized1 = deep_stringify_keys(config1.serialize)

        # Second round-trip
        config2 = described_class.deserialize(serialized1)
        serialized2 = deep_stringify_keys(config2.serialize)

        expect(serialized1).to eq(serialized2)
        expect(config2.automatic_thread_titling.enabled).to eq(original_data["automatic_thread_titling"]["enabled"])
        expect(config2.file_upload.enabled).to eq(original_data["file_upload"]["enabled"])
        expect(config2.file_upload.max_file_size).to eq(original_data["file_upload"]["max_file_size"])
        expect(config2.file_upload.max_files).to eq(original_data["file_upload"]["max_files"])
        expect(config2.history.enabled).to eq(original_data["history"]["enabled"])
        expect(config2.history.recent_threads).to eq(original_data["history"]["recent_threads"])
      end
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

  describe "attribute accessors" do
    let(:config) do
      described_class.new(
        file_upload: { enabled: true, max_file_size: 256, max_files: 5 },
        history: { enabled: true, recent_threads: 50 },
        automatic_thread_titling: { enabled: true }
      )
    end

    describe "#automatic_thread_titling" do
      it "is readable and writable" do
        new_titling = build(:automatic_thread_titling, :disabled)
        config.automatic_thread_titling = new_titling
        expect(config.automatic_thread_titling).to eq(new_titling)
      end
    end

    describe "#file_upload" do
      it "is readable and writable" do
        new_file_upload = build(:file_upload, :large_files)
        config.file_upload = new_file_upload
        expect(config.file_upload).to eq(new_file_upload)
      end
    end

    describe "#history" do
      it "is readable and writable" do
        new_history = build(:history, :limited_threads)
        config.history = new_history
        expect(config.history).to eq(new_history)
      end
    end
  end

  describe "#serialize" do
    context "when all components have values" do
      it "returns a hash with all component serializations" do
        config = described_class.new(
          file_upload: { enabled: false, max_file_size: 256, max_files: 5 },
          history: { enabled: true, recent_threads: 25 },
          automatic_thread_titling: { enabled: true }
        )

        result = config.serialize

        expect(result).to have_key(:automatic_thread_titling)
        expect(result).to have_key(:file_upload)
        expect(result).to have_key(:history)
        expect(result[:automatic_thread_titling]).to eq({ enabled: true })
        expect(result[:file_upload]).to eq({ enabled: false, max_file_size: 256, max_files: 5 })
        expect(result[:history]).to eq({ enabled: true, recent_threads: 25 })
      end
    end

    context "when some components have nil values" do
      it "includes components with empty hashes due to compact behavior" do
        config = described_class.new(
          file_upload: { enabled: nil, max_file_size: 256, max_files: 5 },
          history: { enabled: true, recent_threads: nil },
          automatic_thread_titling: { enabled: nil }
        )

        result = config.serialize

        # Each component's serialize method uses compact, so nil values are removed
        expect(result[:automatic_thread_titling]).to eq({})
        expect(result[:file_upload]).to eq({ max_file_size: 256, max_files: 5 })
        expect(result[:history]).to eq({ enabled: true })
      end
    end

    context "when all components have all nil values" do
      it "returns hash with empty nested hashes" do
        config = described_class.new(
          file_upload: { enabled: nil, max_file_size: nil, max_files: nil },
          history: { enabled: nil, recent_threads: nil },
          automatic_thread_titling: { enabled: nil }
        )

        result = config.serialize

        expect(result).to eq({
          automatic_thread_titling: {},
          file_upload: {},
          history: {},
        })
      end
    end

    context "when using factory bot objects" do
      it "properly serializes factory-created objects" do
        config = build(:chatkit_configuration, :all_enabled)
        result = config.serialize

        expect(result[:automatic_thread_titling]).to eq({ enabled: true })
        expect(result[:file_upload]).to include(:enabled, :max_file_size, :max_files)
        expect(result[:history]).to include(:enabled, :recent_threads)
      end

      it "handles mixed settings from factories" do
        config = build(:chatkit_configuration, :mixed_settings)
        result = config.serialize

        expect(result[:automatic_thread_titling]).to eq({ enabled: true })
        expect(result[:file_upload][:enabled]).to be(false)
        expect(result[:history][:enabled]).to be(true)
        expect(result[:history]).not_to have_key(:recent_threads) # nil was compacted
      end

      it "handles minimal config from factories" do
        config = build(:chatkit_configuration, :minimal_config)
        result = config.serialize

        expect(result).to eq({
          automatic_thread_titling: {},
          file_upload: {},
          history: {},
        })
      end
    end
  end

  describe "integration with individual component factories" do
    it "works with AutomaticThreadTitling factory" do
      titling = build(:automatic_thread_titling, :disabled)
      expect(titling.enabled).to be(false)
    end

    it "works with FileUpload factory" do
      upload = build(:file_upload, :large_files)
      expect(upload.max_file_size).to eq(1024)
      expect(upload.max_files).to eq(20)
    end

    it "works with History factory" do
      history = build(:history, :no_thread_limit)
      expect(history.recent_threads).to be_nil
    end

    it "can create complex configurations using individual factories" do
      config = described_class.new(
        file_upload: attributes_for(:file_upload, :small_files),
        history: attributes_for(:history, :unlimited_threads),
        automatic_thread_titling: attributes_for(:automatic_thread_titling)
      )

      expect(config.automatic_thread_titling.enabled).to be(true)
      expect(config.file_upload.max_file_size).to eq(64)
      expect(config.file_upload.max_files).to eq(2)
      expect(config.history.recent_threads).to eq(1000)
    end
  end

  describe "error handling" do
    context "when FileUpload has only some parameters" do
      it "handles missing max_file_size and max_files gracefully" do
        config = described_class.new(
          file_upload: { enabled: true }, # max_file_size and max_files will be nil
          history: { enabled: true },
          automatic_thread_titling: { enabled: true }
        )

        expect(config.file_upload.enabled).to be(true)
        expect(config.file_upload.max_file_size).to be_nil
        expect(config.file_upload.max_files).to be_nil
      end
    end

    context "when components are not hashes" do
      it "handles non-hash inputs by calling to_h" do
        # This tests the .to_h call in the initializer
        config = described_class.new(
          file_upload: { max_file_size: 256, max_files: 5 },
          history: nil,
          automatic_thread_titling: nil
        )

        # Should not raise error due to .to_h conversion
        expect(config.automatic_thread_titling).to be_a(ChatKit::Session::ChatKitConfiguration::AutomaticThreadTitling)
        expect(config.history).to be_a(ChatKit::Session::ChatKitConfiguration::History)
      end
    end
  end
end
