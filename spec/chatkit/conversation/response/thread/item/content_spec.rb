# frozen_string_literal: true

RSpec.describe ChatKit::Conversation::Response::Thread::Item::Content do
  describe ".new" do
    context "when no arguments are provided" do
      it "initializes with nil type and text" do
        instance = described_class.new
        expect(instance.type).to be_nil
        expect(instance.text).to be_nil
      end
    end

    context "when type is provided" do
      it "initializes with the provided type value" do
        instance = described_class.new(type: "text")
        expect(instance.type).to eq("text")
      end

      it "accepts nil value" do
        instance = described_class.new(type: nil)
        expect(instance.type).to be_nil
      end
    end

    context "when text is provided" do
      it "initializes with the provided text value" do
        instance = described_class.new(text: "Hello, world!")
        expect(instance.text).to eq("Hello, world!")
      end

      it "accepts nil value" do
        instance = described_class.new(text: nil)
        expect(instance.text).to be_nil
      end

      it "accepts empty string" do
        instance = described_class.new(text: "")
        expect(instance.text).to eq("")
      end
    end

    context "when both type and text are provided" do
      it "initializes with both values" do
        instance = described_class.new(type: "text", text: "Hello, world!")
        expect(instance.type).to eq("text")
        expect(instance.text).to eq("Hello, world!")
      end
    end
  end

  describe "attribute accessors" do
    let(:instance) { described_class.new }

    describe "#type" do
      it "allows reading and writing" do
        expect(instance.type).to be_nil
        instance.type = "image"
        expect(instance.type).to eq("image")
      end
    end

    describe "#text" do
      it "allows reading and writing" do
        expect(instance.text).to be_nil
        instance.text = "Updated text"
        expect(instance.text).to eq("Updated text")
      end
    end
  end
end
