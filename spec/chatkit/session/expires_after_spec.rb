# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChatKit::Session::ExpiresAfter do
  describe ".new" do
    context "when both required parameters are provided" do
      it "initializes with anchor and seconds" do
        expires_after = described_class.new(anchor: "creation", seconds: 600)

        expect(expires_after.anchor).to eq("creation")
        expect(expires_after.seconds).to eq(600)
      end
    end

    context "when different anchor types are provided" do
      it "accepts creation anchor" do
        expires_after = described_class.new(anchor: "creation", seconds: 300)

        expect(expires_after.anchor).to eq("creation")
        expect(expires_after.seconds).to eq(300)
      end

      it "accepts last_activity anchor" do
        expires_after = described_class.new(anchor: "last_activity", seconds: 1800)

        expect(expires_after.anchor).to eq("last_activity")
        expect(expires_after.seconds).to eq(1800)
      end

      it "accepts custom anchor values" do
        expires_after = described_class.new(anchor: "custom_timestamp", seconds: 7200)

        expect(expires_after.anchor).to eq("custom_timestamp")
        expect(expires_after.seconds).to eq(7200)
      end
    end

    context "when different time durations are provided" do
      it "accepts short duration (1 minute)" do
        expires_after = described_class.new(anchor: "creation", seconds: 60)

        expect(expires_after.seconds).to eq(60)
      end

      it "accepts standard duration (10 minutes)" do
        expires_after = described_class.new(anchor: "creation", seconds: 600)

        expect(expires_after.seconds).to eq(600)
      end

      it "accepts long duration (1 hour)" do
        expires_after = described_class.new(anchor: "creation", seconds: 3600)

        expect(expires_after.seconds).to eq(3600)
      end

      it "accepts very long duration (24 hours)" do
        expires_after = described_class.new(anchor: "creation", seconds: 86_400)

        expect(expires_after.seconds).to eq(86_400)
      end
    end

    context "when zero or negative values are provided" do
      it "accepts zero seconds" do
        expires_after = described_class.new(anchor: "creation", seconds: 0)

        expect(expires_after.seconds).to eq(0)
      end

      it "accepts negative seconds" do
        expires_after = described_class.new(anchor: "creation", seconds: -100)

        expect(expires_after.seconds).to eq(-100)
      end
    end
  end

  describe ".build" do
    context "when both parameters are provided" do
      it "creates instance with provided values" do
        expires_after = described_class.build(anchor: "last_activity", seconds: 1200)

        expect(expires_after.anchor).to eq("last_activity")
        expect(expires_after.seconds).to eq(1200)
      end
    end

    context "when comparing with .new method" do
      it "produces identical results" do
        params = { anchor: "creation", seconds: 900 }

        expires_new = described_class.new(**params)
        expires_build = described_class.build(**params)

        expect(expires_new.anchor).to eq(expires_build.anchor)
        expect(expires_new.seconds).to eq(expires_build.seconds)
        expect(expires_new.serialize).to eq(expires_build.serialize)
      end
    end
  end

  describe "attribute accessors" do
    let(:expires_after) { described_class.new(anchor: "creation", seconds: 600) }

    describe "#anchor" do
      it "is readable and writable" do
        expect(expires_after.anchor).to eq("creation")
        expires_after.anchor = "last_activity"
        expect(expires_after.anchor).to eq("last_activity")
      end

      it "accepts string values" do
        expires_after.anchor = "custom_anchor"
        expect(expires_after.anchor).to eq("custom_anchor")
      end

      it "accepts nil value" do
        expires_after.anchor = nil
        expect(expires_after.anchor).to be_nil
      end
    end

    describe "#seconds" do
      it "is readable and writable" do
        expect(expires_after.seconds).to eq(600)
        expires_after.seconds = 1800
        expect(expires_after.seconds).to eq(1800)
      end

      it "accepts integer values" do
        expires_after.seconds = 42
        expect(expires_after.seconds).to eq(42)
      end

      it "accepts zero value" do
        expires_after.seconds = 0
        expect(expires_after.seconds).to eq(0)
      end

      it "accepts negative values" do
        expires_after.seconds = -500
        expect(expires_after.seconds).to eq(-500)
      end

      it "accepts nil value" do
        expires_after.seconds = nil
        expect(expires_after.seconds).to be_nil
      end
    end
  end

  describe "#serialize" do
    context "when both attributes have values" do
      let(:expires_after) { described_class.new(anchor: "creation", seconds: 1200) }

      it "returns hash with both attributes" do
        result = expires_after.serialize

        expect(result).to eq({
          anchor: "creation",
          seconds: 1200,
        })
      end
    end

    context "when attributes have different combinations" do
      it "includes both anchor and seconds when set" do
        expires_after = described_class.new(anchor: "last_activity", seconds: 300)
        result = expires_after.serialize

        expect(result).to have_key(:anchor)
        expect(result).to have_key(:seconds)
        expect(result[:anchor]).to eq("last_activity")
        expect(result[:seconds]).to eq(300)
      end

      it "includes zero seconds in serialization" do
        expires_after = described_class.new(anchor: "creation", seconds: 0)
        result = expires_after.serialize

        expect(result[:seconds]).to eq(0)
        expect(result).to have_key(:seconds)
      end

      it "includes negative seconds in serialization" do
        expires_after = described_class.new(anchor: "creation", seconds: -100)
        result = expires_after.serialize

        expect(result[:seconds]).to eq(-100)
      end
    end

    context "when attributes are set to nil" do
      it "excludes nil anchor due to compact" do
        expires_after = described_class.new(anchor: "creation", seconds: 600)
        expires_after.anchor = nil
        result = expires_after.serialize

        expect(result).not_to have_key(:anchor)
        expect(result[:seconds]).to eq(600)
      end

      it "excludes nil seconds due to compact" do
        expires_after = described_class.new(anchor: "creation", seconds: 600)
        expires_after.seconds = nil
        result = expires_after.serialize

        expect(result).not_to have_key(:seconds)
        expect(result[:anchor]).to eq("creation")
      end

      it "returns empty hash when both are nil" do
        expires_after = described_class.new(anchor: "creation", seconds: 600)
        expires_after.anchor = nil
        expires_after.seconds = nil
        result = expires_after.serialize

        expect(result).to eq({})
      end
    end
  end

  describe "edge cases and validation" do
    context "with boundary values" do
      it "handles empty string anchor" do
        expires_after = described_class.new(anchor: "", seconds: 600)
        expect(expires_after.anchor).to eq("")
      end

      it "handles very long anchor string" do
        long_anchor = "anchor_#{'x' * 1000}"
        expires_after = described_class.new(anchor: long_anchor, seconds: 600)
        expect(expires_after.anchor).to eq(long_anchor)
      end

      it "handles maximum integer seconds" do
        max_seconds = (2**31) - 1 # Maximum 32-bit signed integer
        expires_after = described_class.new(anchor: "creation", seconds: max_seconds)
        expect(expires_after.seconds).to eq(max_seconds)
      end

      it "handles minimum integer seconds" do
        min_seconds = -2**31 # Minimum 32-bit signed integer
        expires_after = described_class.new(anchor: "creation", seconds: min_seconds)
        expect(expires_after.seconds).to eq(min_seconds)
      end
    end

    context "when checking serialization consistency" do
      it "maintains consistent serialization across multiple calls" do
        expires_after = described_class.new(anchor: "creation", seconds: 1800)

        first_serialize = expires_after.serialize
        second_serialize = expires_after.serialize

        expect(first_serialize).to eq(second_serialize)
      end

      it "reflects changes in subsequent serializations" do
        expires_after = described_class.new(anchor: "creation", seconds: 600)

        original_serialize = expires_after.serialize
        expires_after.seconds = 1200
        updated_serialize = expires_after.serialize

        expect(original_serialize[:seconds]).to eq(600)
        expect(updated_serialize[:seconds]).to eq(1200)
      end

      it "reflects anchor changes in serializations" do
        expires_after = described_class.new(anchor: "creation", seconds: 600)

        original_serialize = expires_after.serialize
        expires_after.anchor = "last_activity"
        updated_serialize = expires_after.serialize

        expect(original_serialize[:anchor]).to eq("creation")
        expect(updated_serialize[:anchor]).to eq("last_activity")
      end
    end

    context "with common expiration scenarios" do
      it "handles default 10-minute expiration" do
        expires_after = described_class.new(anchor: "creation", seconds: 600)
        result = expires_after.serialize

        expect(result).to eq({ anchor: "creation", seconds: 600 })
      end

      it "handles session timeout scenarios" do
        expires_after = described_class.new(anchor: "last_activity", seconds: 1800)
        result = expires_after.serialize

        expect(result[:anchor]).to eq("last_activity")
        expect(result[:seconds]).to eq(1800)
      end

      it "handles immediate expiration" do
        expires_after = described_class.new(anchor: "creation", seconds: 0)
        result = expires_after.serialize

        expect(result[:seconds]).to eq(0)
      end
    end
  end
end
