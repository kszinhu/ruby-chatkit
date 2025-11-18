# frozen_string_literal: true

RSpec.describe ChatKit::Session::RateLimits do
  describe ".new" do
    context "when no arguments are provided" do
      it "initializes with default max_requests_per_1_minute value" do
        instance = described_class.new
        expect(instance.max_requests_per_1_minute).to eq(described_class::Defaults::MAX_REQUESTS_PER_1_MINUTE)
      end
    end

    context "when max_requests_per_1_minute is provided" do
      it "initializes with the provided value" do
        instance = described_class.new(max_requests_per_1_minute: 25)
        expect(instance.max_requests_per_1_minute).to eq(25)
      end

      it "accepts zero value" do
        instance = described_class.new(max_requests_per_1_minute: 0)
        expect(instance.max_requests_per_1_minute).to eq(0)
      end

      it "accepts large values" do
        instance = described_class.new(max_requests_per_1_minute: 1000)
        expect(instance.max_requests_per_1_minute).to eq(1000)
      end

      it "accepts nil value" do
        instance = described_class.new(max_requests_per_1_minute: nil)
        expect(instance.max_requests_per_1_minute).to be_nil
      end
    end
  end

  describe ".build" do
    context "when no arguments are provided" do
      it "creates an instance with nil max_requests_per_1_minute value" do
        instance = described_class.build
        expect(instance.max_requests_per_1_minute).to be_nil
      end
    end

    context "when max_requests_per_1_minute is provided" do
      it "creates an instance with the provided value" do
        instance = described_class.build(max_requests_per_1_minute: 50)
        expect(instance.max_requests_per_1_minute).to eq(50)
      end

      it "accepts zero value" do
        instance = described_class.build(max_requests_per_1_minute: 0)
        expect(instance.max_requests_per_1_minute).to eq(0)
      end

      it "accepts nil value explicitly" do
        instance = described_class.build(max_requests_per_1_minute: nil)
        expect(instance.max_requests_per_1_minute).to be_nil
      end
    end
  end

  describe "#max_requests_per_1_minute" do
    it "is readable" do
      instance = described_class.new(max_requests_per_1_minute: 15)
      expect(instance.max_requests_per_1_minute).to eq(15)
    end

    it "is writable" do
      instance = described_class.new(max_requests_per_1_minute: 10)
      instance.max_requests_per_1_minute = 20
      expect(instance.max_requests_per_1_minute).to eq(20)
    end

    it "accepts integer values" do
      instance = described_class.new

      instance.max_requests_per_1_minute = 5
      expect(instance.max_requests_per_1_minute).to eq(5)

      instance.max_requests_per_1_minute = 100
      expect(instance.max_requests_per_1_minute).to eq(100)
    end

    it "accepts nil value" do
      instance = described_class.new(max_requests_per_1_minute: 10)
      instance.max_requests_per_1_minute = nil
      expect(instance.max_requests_per_1_minute).to be_nil
    end

    it "accepts zero value" do
      instance = described_class.new
      instance.max_requests_per_1_minute = 0
      expect(instance.max_requests_per_1_minute).to eq(0)
    end
  end

  describe "#serialize" do
    context "when max_requests_per_1_minute has a value" do
      it "returns a hash with max_requests_per_1_minute key" do
        instance = described_class.new(max_requests_per_1_minute: 30)
        result = instance.serialize

        expect(result).to eq({ max_requests_per_1_minute: 30 })
      end

      it "includes zero values" do
        instance = described_class.new(max_requests_per_1_minute: 0)
        result = instance.serialize

        expect(result).to eq({ max_requests_per_1_minute: 0 })
      end
    end

    context "when max_requests_per_1_minute is nil" do
      it "returns an empty hash due to compact" do
        instance = described_class.new(max_requests_per_1_minute: nil)
        result = instance.serialize

        expect(result).to eq({})
      end
    end

    context "when using default value" do
      it "returns a hash with the default max_requests_per_1_minute value" do
        instance = described_class.new
        result = instance.serialize

        expect(result).to eq({ max_requests_per_1_minute: described_class::Defaults::MAX_REQUESTS_PER_1_MINUTE })
      end
    end

    context "when value is changed after initialization" do
      it "returns the updated value" do
        instance = described_class.new(max_requests_per_1_minute: 10)
        instance.max_requests_per_1_minute = 25
        result = instance.serialize

        expect(result).to eq({ max_requests_per_1_minute: 25 })
      end

      it "returns empty hash when changed to nil" do
        instance = described_class.new(max_requests_per_1_minute: 10)
        instance.max_requests_per_1_minute = nil
        result = instance.serialize

        expect(result).to eq({})
      end
    end

    context "when built with build method" do
      it "returns empty hash for default build" do
        instance = described_class.build
        result = instance.serialize

        expect(result).to eq({})
      end

      it "returns hash with value when provided to build" do
        instance = described_class.build(max_requests_per_1_minute: 15)
        result = instance.serialize

        expect(result).to eq({ max_requests_per_1_minute: 15 })
      end
    end
  end

  describe "::Defaults" do
    it "defines MAX_REQUESTS_PER_1_MINUTE constant" do
      expect(described_class::Defaults::MAX_REQUESTS_PER_1_MINUTE).to eq(10)
    end
  end

  describe "edge cases and validation" do
    context "with boundary values" do
      it "handles minimum positive value" do
        instance = described_class.new(max_requests_per_1_minute: 1)
        expect(instance.max_requests_per_1_minute).to eq(1)
        expect(instance.serialize).to eq({ max_requests_per_1_minute: 1 })
      end

      it "handles large values" do
        instance = described_class.new(max_requests_per_1_minute: 9999)
        expect(instance.max_requests_per_1_minute).to eq(9999)
        expect(instance.serialize).to eq({ max_requests_per_1_minute: 9999 })
      end
    end

    context "when comparing new vs build methods" do
      it "shows different default behaviors" do
        new_instance = described_class.new
        build_instance = described_class.build

        expect(new_instance.max_requests_per_1_minute).to eq(10) # default
        expect(build_instance.max_requests_per_1_minute).to be_nil # nil
      end

      it "produces same result when same value is provided" do
        new_instance = described_class.new(max_requests_per_1_minute: 20)
        build_instance = described_class.build(max_requests_per_1_minute: 20)

        expect(new_instance.max_requests_per_1_minute).to eq(build_instance.max_requests_per_1_minute)
        expect(new_instance.serialize).to eq(build_instance.serialize)
      end
    end

    context "when checking serialization consistency" do
      it "maintains consistency across multiple serialize calls" do
        instance = described_class.new(max_requests_per_1_minute: 42)

        first_serialize = instance.serialize
        second_serialize = instance.serialize

        expect(first_serialize).to eq(second_serialize)
      end

      it "reflects changes in subsequent serializations" do
        instance = described_class.new(max_requests_per_1_minute: 5)

        original_serialize = instance.serialize
        instance.max_requests_per_1_minute = 10
        updated_serialize = instance.serialize

        expect(original_serialize).to eq({ max_requests_per_1_minute: 5 })
        expect(updated_serialize).to eq({ max_requests_per_1_minute: 10 })
      end
    end
  end
end
