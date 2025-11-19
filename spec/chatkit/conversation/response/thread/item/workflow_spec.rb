# frozen_string_literal: true

RSpec.describe ChatKit::Conversation::Response::Thread::Item::Workflow do
  describe ".new" do
    context "when no arguments are provided" do
      it "initializes with nil values for all attributes" do
        instance = described_class.new
        expect(instance.type).to be_nil
        expect(instance.tasks).to be_nil
        expect(instance.summary).to be_nil
        expect(instance.expanded).to be_nil
        expect(instance.response_items).to be_nil
      end
    end

    context "when type is provided" do
      it "initializes with the provided type value" do
        instance = described_class.new(type: "sequential")
        expect(instance.type).to eq("sequential")
      end

      it "accepts nil value" do
        instance = described_class.new(type: nil)
        expect(instance.type).to be_nil
      end
    end

    context "when tasks is provided" do
      it "initializes with the provided tasks array" do
        tasks = [{ "id" => "task1" }, { "id" => "task2" }]
        instance = described_class.new(tasks:)
        expect(instance.tasks).to eq(tasks)
      end

      it "accepts empty array" do
        instance = described_class.new(tasks: [])
        expect(instance.tasks).to eq([])
      end

      it "accepts nil value" do
        instance = described_class.new(tasks: nil)
        expect(instance.tasks).to be_nil
      end
    end

    context "when summary is provided" do
      it "initializes with the provided summary hash" do
        summary = { "total" => 5, "completed" => 3 }
        instance = described_class.new(summary:)
        expect(instance.summary).to eq(summary)
      end

      it "accepts empty hash" do
        instance = described_class.new(summary: {})
        expect(instance.summary).to eq({})
      end

      it "accepts nil value" do
        instance = described_class.new(summary: nil)
        expect(instance.summary).to be_nil
      end
    end

    context "when expanded is provided" do
      it "initializes with true value" do
        instance = described_class.new(expanded: true)
        expect(instance.expanded).to be(true)
      end

      it "initializes with false value" do
        instance = described_class.new(expanded: false)
        expect(instance.expanded).to be(false)
      end

      it "accepts nil value" do
        instance = described_class.new(expanded: nil)
        expect(instance.expanded).to be_nil
      end
    end

    context "when response_items is provided" do
      it "initializes with the provided response_items array" do
        items = [{ "id" => "item1" }, { "id" => "item2" }]
        instance = described_class.new(response_items: items)
        expect(instance.response_items).to eq(items)
      end

      it "accepts empty array" do
        instance = described_class.new(response_items: [])
        expect(instance.response_items).to eq([])
      end

      it "accepts nil value" do
        instance = described_class.new(response_items: nil)
        expect(instance.response_items).to be_nil
      end
    end

    context "when all parameters are provided" do
      it "initializes with all values" do
        instance = described_class.new(
          type: "parallel",
          tasks: [{ "id" => "task1" }],
          summary: { "total" => 1 },
          expanded: true,
          response_items: [{ "id" => "item1" }]
        )
        expect(instance.type).to eq("parallel")
        expect(instance.tasks).to eq([{ "id" => "task1" }])
        expect(instance.summary).to eq({ "total" => 1 })
        expect(instance.expanded).to be(true)
        expect(instance.response_items).to eq([{ "id" => "item1" }])
      end
    end
  end

  describe ".from_event" do
    it "creates a Workflow from event data" do
      event_data = {
        "type" => "sequential",
        "tasks" => [{ "id" => "task1" }],
        "summary" => { "total" => 1 },
        "expanded" => true,
        "response_items" => [{ "id" => "item1" }],
      }

      instance = described_class.from_event(event_data)

      expect(instance.type).to eq("sequential")
      expect(instance.tasks).to eq([{ "id" => "task1" }])
      expect(instance.summary).to eq({ "total" => 1 })
      expect(instance.expanded).to be(true)
      expect(instance.response_items).to eq([{ "id" => "item1" }])
    end

    it "handles partial event data" do
      event_data = {
        "type" => "parallel",
        "tasks" => [{ "id" => "task1" }],
      }

      instance = described_class.from_event(event_data)

      expect(instance.type).to eq("parallel")
      expect(instance.tasks).to eq([{ "id" => "task1" }])
      expect(instance.summary).to be_nil
      expect(instance.expanded).to be_nil
      expect(instance.response_items).to be_nil
    end

    it "handles empty event data" do
      instance = described_class.from_event({})

      expect(instance.type).to be_nil
      expect(instance.tasks).to be_nil
      expect(instance.summary).to be_nil
      expect(instance.expanded).to be_nil
      expect(instance.response_items).to be_nil
    end
  end

  describe "#update!" do
    let(:instance) do
      described_class.new(
        type: "sequential",
        tasks: [{ "id" => "task1" }],
        summary: { "total" => 1 },
        expanded: false,
        response_items: [{ "id" => "item1" }]
      )
    end

    it "updates type when provided" do
      instance.update!({ "type" => "parallel" })
      expect(instance.type).to eq("parallel")
    end

    it "updates tasks when provided" do
      new_tasks = [{ "id" => "task2" }]
      instance.update!({ "tasks" => new_tasks })
      expect(instance.tasks).to eq(new_tasks)
    end

    it "updates summary when provided" do
      new_summary = { "total" => 2, "completed" => 1 }
      instance.update!({ "summary" => new_summary })
      expect(instance.summary).to eq(new_summary)
    end

    it "updates expanded when provided" do
      instance.update!({ "expanded" => true })
      expect(instance.expanded).to be(true)
    end

    it "updates response_items when provided" do
      new_items = [{ "id" => "item2" }]
      instance.update!({ "response_items" => new_items })
      expect(instance.response_items).to eq(new_items)
    end

    it "updates multiple attributes at once" do
      instance.update!({
        "type" => "parallel",
        "summary" => { "total" => 5 },
        "expanded" => true,
      })

      expect(instance.type).to eq("parallel")
      expect(instance.summary).to eq({ "total" => 5 })
      expect(instance.expanded).to be(true)
      expect(instance.tasks).to eq([{ "id" => "task1" }]) # unchanged
      expect(instance.response_items).to eq([{ "id" => "item1" }]) # unchanged
    end

    it "does not update attributes not present in data" do
      original_type = instance.type
      original_tasks = instance.tasks

      instance.update!({ "summary" => { "total" => 3 } })

      expect(instance.type).to eq(original_type)
      expect(instance.tasks).to eq(original_tasks)
      expect(instance.summary).to eq({ "total" => 3 })
    end

    it "handles empty update data" do
      original_values = {
        type: instance.type,
        tasks: instance.tasks,
        summary: instance.summary,
        expanded: instance.expanded,
        response_items: instance.response_items,
      }

      instance.update!({})

      expect(instance.type).to eq(original_values[:type])
      expect(instance.tasks).to eq(original_values[:tasks])
      expect(instance.summary).to eq(original_values[:summary])
      expect(instance.expanded).to eq(original_values[:expanded])
      expect(instance.response_items).to eq(original_values[:response_items])
    end
  end

  describe "attribute accessors" do
    let(:instance) { described_class.new }

    describe "#type" do
      it "allows reading and writing" do
        expect(instance.type).to be_nil
        instance.type = "parallel"
        expect(instance.type).to eq("parallel")
      end
    end

    describe "#tasks" do
      it "allows reading and writing" do
        expect(instance.tasks).to be_nil
        tasks = [{ "id" => "task1" }]
        instance.tasks = tasks
        expect(instance.tasks).to eq(tasks)
      end
    end

    describe "#summary" do
      it "allows reading and writing" do
        expect(instance.summary).to be_nil
        summary = { "total" => 5 }
        instance.summary = summary
        expect(instance.summary).to eq(summary)
      end
    end

    describe "#expanded" do
      it "allows reading and writing" do
        expect(instance.expanded).to be_nil
        instance.expanded = true
        expect(instance.expanded).to be(true)
      end
    end

    describe "#response_items" do
      it "allows reading and writing" do
        expect(instance.response_items).to be_nil
        items = [{ "id" => "item1" }]
        instance.response_items = items
        expect(instance.response_items).to eq(items)
      end
    end
  end
end
