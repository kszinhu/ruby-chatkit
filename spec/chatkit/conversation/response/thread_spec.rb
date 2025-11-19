# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChatKit::Conversation::Response::Thread do
  describe ".new" do
    context "when no arguments are provided" do
      it "initializes with default values" do
        instance = described_class.new
        expect(instance.id).to be_nil
        expect(instance.created_at).to be_nil
        expect(instance.status).to be_nil
        expect(instance.title).to be_nil
        expect(instance.metadata).to be_nil
        expect(instance.items).to eq([])
      end
    end

    context "when id is provided" do
      it "initializes with the provided id value" do
        instance = described_class.new(id: "cthr_123")
        expect(instance.id).to eq("cthr_123")
      end
    end

    context "when created_at is provided" do
      it "initializes with the provided created_at value" do
        timestamp = "2025-11-19T10:30:00Z"
        instance = described_class.new(created_at: timestamp)
        expect(instance.created_at).to eq(timestamp)
      end
    end

    context "when status is provided" do
      it "initializes with the provided status value" do
        status = { "type" => "active" }
        instance = described_class.new(status:)
        expect(instance.status).to eq(status)
      end
    end

    context "when title is provided" do
      it "initializes with the provided title value" do
        instance = described_class.new(title: "My Thread")
        expect(instance.title).to eq("My Thread")
      end
    end

    context "when metadata is provided" do
      it "initializes with the provided metadata value" do
        metadata = { "key" => "value" }
        instance = described_class.new(metadata:)
        expect(instance.metadata).to eq(metadata)
      end
    end

    context "when all parameters are provided" do
      it "initializes with all values" do
        instance = described_class.new(
          id: "cthr_123",
          created_at: "2025-11-19T10:30:00Z",
          status: { "type" => "active" },
          title: "My Thread",
          metadata: { "key" => "value" }
        )

        expect(instance.id).to eq("cthr_123")
        expect(instance.created_at).to eq("2025-11-19T10:30:00Z")
        expect(instance.status).to eq({ "type" => "active" })
        expect(instance.title).to eq("My Thread")
        expect(instance.metadata).to eq({ "key" => "value" })
        expect(instance.items).to eq([])
      end
    end
  end

  describe "#update!" do
    let(:instance) { described_class.new }

    it "updates id when provided" do
      instance.update!({ "thread" => { "id" => "cthr_123" } })
      expect(instance.id).to eq("cthr_123")
    end

    it "updates created_at when provided" do
      timestamp = "2025-11-19T10:30:00Z"
      instance.update!({ "thread" => { "created_at" => timestamp } })
      expect(instance.created_at).to eq(timestamp)
    end

    it "updates status when provided" do
      status = { "type" => "active" }
      instance.update!({ "thread" => { "status" => status } })
      expect(instance.status).to eq(status)
    end

    it "updates title when provided" do
      instance.update!({ "thread" => { "title" => "Updated Title" } })
      expect(instance.title).to eq("Updated Title")
    end

    it "updates metadata when provided" do
      metadata = { "key" => "value" }
      instance.update!({ "thread" => { "metadata" => metadata } })
      expect(instance.metadata).to eq(metadata)
    end

    it "updates multiple attributes at once" do
      instance.update!({
        "thread" => {
          "id" => "cthr_456",
          "title" => "New Title",
          "status" => { "type" => "completed" },
        },
      })

      expect(instance.id).to eq("cthr_456")
      expect(instance.title).to eq("New Title")
      expect(instance.status).to eq({ "type" => "completed" })
    end

    it "does not update attributes not present in thread data" do
      instance.id = "cthr_original"
      instance.title = "Original Title"

      instance.update!({ "thread" => { "status" => { "type" => "active" } } })

      expect(instance.id).to eq("cthr_original")
      expect(instance.title).to eq("Original Title")
      expect(instance.status).to eq({ "type" => "active" })
    end

    it "handles empty thread data" do
      instance.id = "cthr_123"
      instance.update!({ "thread" => {} })
      expect(instance.id).to eq("cthr_123")
    end

    it "handles missing thread key" do
      instance.id = "cthr_123"
      instance.update!({})
      expect(instance.id).to eq("cthr_123")
    end

    it "can update from thread.created event format" do
      event = {
        "thread" => {
          "id" => "cthr_123",
          "created_at" => "2025-11-11T11:32:33.784959",
          "status" => { "type" => "active" },
          "metadata" => {},
        },
      }

      instance.update!(event)

      expect(instance.id).to eq("cthr_123")
      expect(instance.created_at).to eq("2025-11-11T11:32:33.784959")
      expect(instance.status).to eq({ "type" => "active" })
      expect(instance.metadata).to eq({})
    end

    it "can update from thread.updated event format" do
      instance.id = "cthr_123"

      event = {
        "thread" => {
          "title" => "Warm Welcome Conversation",
        },
      }

      instance.update!(event)

      expect(instance.id).to eq("cthr_123")
      expect(instance.title).to eq("Warm Welcome Conversation")
    end
  end

  describe "#add_or_update_item!" do
    let(:instance) { described_class.new }

    context "with user_message type" do
      it "creates a new item and adds it to items" do
        event = {
          "item" => {
            "id" => "cti_user_1",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-19T10:30:00Z",
            "type" => "user_message",
            "content" => [{ "type" => "input_text", "text" => "Hello" }],
            "attachments" => [],
            "quoted_text" => "",
            "inference_options" => {},
          },
        }

        item = instance.add_or_update_item!(event)

        expect(instance.items.size).to eq(1)
        expect(item.id).to eq("cti_user_1")
        expect(item.thread_id).to eq("cthr_123")
        expect(item.content.size).to eq(1)
        expect(item.content.first.type).to eq("input_text")
        expect(item.content.first.text).to eq("Hello")
      end

      it "starts a new conversation turn with each user message" do
        # First user message
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_user_1",
            "type" => "user_message",
            "content" => [{ "type" => "input_text", "text" => "First" }],
          },
        })

        # Second user message
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_user_2",
            "type" => "user_message",
            "content" => [{ "type" => "input_text", "text" => "Second" }],
          },
        })

        expect(instance.items.size).to eq(2)
        expect(instance.items.first.id).to eq("cti_user_1")
        expect(instance.items.last.id).to eq("cti_user_2")
      end
    end

    context "with assistant_message type" do
      it "creates or updates current item" do
        event = {
          "item" => {
            "id" => "cti_assistant_1",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-19T10:30:00Z",
            "type" => "assistant_message",
            "content" => [{ "type" => "output_text", "text" => "Response" }],
          },
        }

        item = instance.add_or_update_item!(event)

        expect(instance.items.size).to eq(1)
        expect(item.id).to eq("cti_assistant_1")
        expect(item.content.first.type).to eq("output_text")
      end

      it "updates the same item when called multiple times" do
        # First call
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_assistant_1",
            "type" => "assistant_message",
            "content" => [{ "type" => "output_text", "text" => "Hello" }],
          },
        })

        expect(instance.items.size).to eq(1)

        # Second call - should update the same item
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_assistant_1",
            "type" => "assistant_message",
            "content" => [{ "type" => "text", "text" => "Complete" }],
          },
        })

        expect(instance.items.size).to eq(1)
        expect(instance.items.first.id).to eq("cti_assistant_1")
      end
    end

    context "with workflow type" do
      it "creates or updates current item with workflow data" do
        event = {
          "item" => {
            "id" => "cti_workflow_1",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-19T10:30:00Z",
            "type" => "workflow",
            "workflow" => {
              "type" => "reasoning",
              "tasks" => [],
              "expanded" => false,
            },
          },
        }

        item = instance.add_or_update_item!(event)

        expect(instance.items.size).to eq(1)
        expect(item.id).to eq("cti_workflow_1")
        expect(item.workflow).not_to be_nil
        expect(item.workflow.type).to eq("reasoning")
      end

      it "updates workflow item when called multiple times" do
        # First call
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_workflow_1",
            "type" => "workflow",
            "workflow" => {
              "type" => "reasoning",
              "tasks" => [],
              "expanded" => false,
            },
          },
        })

        expect(instance.items.size).to eq(1)
        expect(instance.items.first.workflow.summary).to be_nil

        # Second call with summary
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_workflow_1",
            "type" => "workflow",
            "workflow" => {
              "type" => "reasoning",
              "summary" => { "duration" => 5 },
            },
          },
        })

        expect(instance.items.size).to eq(1)
        expect(instance.items.first.workflow.summary).to eq({ "duration" => 5 })
      end
    end

    context "with missing item data" do
      it "handles empty item data" do
        event = { "item" => {} }
        item = instance.add_or_update_item!(event)

        expect(instance.items.size).to eq(1)
        expect(item).not_to be_nil
      end

      it "handles missing item key" do
        event = {}
        item = instance.add_or_update_item!(event)

        expect(instance.items.size).to eq(1)
        expect(item).not_to be_nil
      end
    end

    context "thread safety" do
      it "is thread-safe when adding items concurrently" do
        threads = 10.times.map do |i|
          Thread.new do
            instance.add_or_update_item!({
              "item" => {
                "id" => "cti_user_#{i}",
                "type" => "user_message",
                "content" => [{ "type" => "input_text", "text" => "Message #{i}" }],
              },
            })
          end
        end

        threads.each(&:join)

        expect(instance.items.size).to eq(10)
      end
    end
  end

  describe "#update_item!" do
    let(:instance) { described_class.new }

    context "when there is a current item" do
      it "updates the current item with the update data" do
        # Create an item first
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_1",
            "type" => "assistant_message",
            "content" => [{ "type" => "output_text", "text" => "" }],
          },
        })

        # Update it with text delta
        instance.update_item!({
          "update" => {
            "type" => "assistant_message.content_part.text_delta",
            "delta" => "Hello",
          },
        })

        item = instance.items.first
        expect(item.content.first.text).to eq("Hello")
        expect(item.delta).to eq(["Hello"])
      end

      it "handles multiple updates to the same item" do
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_1",
            "type" => "assistant_message",
            "content" => [{ "type" => "output_text", "text" => "" }],
          },
        })

        instance.update_item!({
          "update" => {
            "type" => "assistant_message.content_part.text_delta",
            "delta" => "Hello",
          },
        })

        instance.update_item!({
          "update" => {
            "type" => "assistant_message.content_part.text_delta",
            "delta" => " world",
          },
        })

        item = instance.items.first
        expect(item.content.first.text).to eq("Hello world")
      end

      it "updates workflow data" do
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_workflow_1",
            "type" => "workflow",
            "workflow" => {
              "type" => "reasoning",
            },
          },
        })

        instance.update_item!({
          "update" => {
            "type" => "workflow.task.added",
            "tasks" => [{ "id" => "task1" }],
          },
        })

        item = instance.items.first
        expect(item.workflow.tasks).to eq([{ "id" => "task1" }])
      end
    end

    context "when there is no current item but items exist" do
      it "updates the last item" do
        # Add a user message (creates new item)
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_1",
            "type" => "user_message",
            "content" => [{ "type" => "input_text", "text" => "Hello" }],
          },
        })

        # Add an assistant message (updates the same current item)
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_1",
            "type" => "assistant_message",
            "content" => [{ "type" => "output_text", "text" => "" }],
          },
        })

        # Update should affect the last item
        instance.update_item!({
          "update" => {
            "type" => "assistant_message.content_part.text_delta",
            "delta" => "Response",
          },
        })

        expect(instance.items.size).to eq(1)
        expect(instance.items.last.content.last.text).to eq("Response")
      end
    end

    context "when there are no items" do
      it "returns nil without error" do
        result = instance.update_item!({
          "update" => {
            "type" => "assistant_message.content_part.text_delta",
            "delta" => "Hello",
          },
        })

        expect(result).to be_nil
        expect(instance.items).to be_empty
      end
    end

    context "with missing update data" do
      it "handles empty update data" do
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_1",
            "type" => "assistant_message",
          },
        })

        expect do
          instance.update_item!({ "update" => {} })
        end.not_to raise_error
      end

      it "handles missing update key" do
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_1",
            "type" => "assistant_message",
          },
        })

        expect do
          instance.update_item!({})
        end.not_to raise_error
      end
    end

    context "thread safety" do
      it "is thread-safe when updating items concurrently" do
        instance.add_or_update_item!({
          "item" => {
            "id" => "cti_1",
            "type" => "assistant_message",
            "content" => [{ "type" => "output_text", "text" => "" }],
          },
        })

        threads = 10.times.map do |i|
          Thread.new do
            instance.update_item!({
              "update" => {
                "type" => "assistant_message.content_part.text_delta",
                "delta" => "#{i}",
              },
            })
          end
        end

        threads.each(&:join)

        # All deltas should be captured
        expect(instance.items.first.delta.size).to eq(10)
      end
    end
  end

  describe "attribute accessors" do
    let(:instance) { described_class.new }

    describe "#id" do
      it "allows reading and writing" do
        expect(instance.id).to be_nil
        instance.id = "cthr_new"
        expect(instance.id).to eq("cthr_new")
      end
    end

    describe "#created_at" do
      it "allows reading and writing" do
        expect(instance.created_at).to be_nil
        timestamp = "2025-11-19T10:30:00Z"
        instance.created_at = timestamp
        expect(instance.created_at).to eq(timestamp)
      end
    end

    describe "#status" do
      it "allows reading and writing" do
        expect(instance.status).to be_nil
        status = { "type" => "active" }
        instance.status = status
        expect(instance.status).to eq(status)
      end
    end

    describe "#title" do
      it "allows reading and writing" do
        expect(instance.title).to be_nil
        instance.title = "New Title"
        expect(instance.title).to eq("New Title")
      end
    end

    describe "#metadata" do
      it "allows reading and writing" do
        expect(instance.metadata).to be_nil
        metadata = { "key" => "value" }
        instance.metadata = metadata
        expect(instance.metadata).to eq(metadata)
      end
    end

    describe "#items" do
      it "allows reading and writing" do
        expect(instance.items).to eq([])
        items = [ChatKit::Conversation::Response::Thread::Item.new(id: "cti_1")]
        instance.items = items
        expect(instance.items).to eq(items)
      end
    end
  end

  describe "integration scenarios" do
    let(:instance) { described_class.new }

    it "handles a complete conversation flow" do
      # Thread created
      instance.update!({
        "thread" => {
          "id" => "cthr_123",
          "created_at" => "2025-11-19T10:30:00Z",
          "status" => { "type" => "active" },
        },
      })

      # User message
      instance.add_or_update_item!({
        "item" => {
          "id" => "cti_user_1",
          "type" => "user_message",
          "content" => [{ "type" => "input_text", "text" => "Hello" }],
        },
      })

      # Assistant message starts
      instance.add_or_update_item!({
        "item" => {
          "id" => "cti_assistant_1",
          "type" => "assistant_message",
          "content" => [{ "type" => "output_text", "text" => "" }],
        },
      })

      # Text streaming
      instance.update_item!({
        "update" => {
          "type" => "assistant_message.content_part.text_delta",
          "delta" => "Hi",
        },
      })

      instance.update_item!({
        "update" => {
          "type" => "assistant_message.content_part.text_delta",
          "delta" => " there",
        },
      })

      # Content part done
      instance.update_item!({
        "update" => {
          "type" => "assistant_message.content_part.done",
          "content" => {
            "type" => "text",
            "text" => "Hi there",
          },
        },
      })

      # Thread updated with title
      instance.update!({
        "thread" => {
          "title" => "Greeting",
        },
      })

      expect(instance.id).to eq("cthr_123")
      expect(instance.title).to eq("Greeting")
      expect(instance.items.size).to eq(1)
      expect(instance.items.first.content.first.text).to eq("Hello")
      expect(instance.items.first.content.last.text).to eq("Hi there")
    end

    it "handles workflow with assistant message" do
      # Workflow starts
      instance.add_or_update_item!({
        "item" => {
          "id" => "cti_workflow_1",
          "type" => "workflow",
          "workflow" => {
            "type" => "reasoning",
            "tasks" => [],
            "expanded" => false,
          },
        },
      })

      # Workflow task added
      instance.update_item!({
        "update" => {
          "type" => "workflow.task.added",
          "tasks" => [{ "id" => "task1", "description" => "Analyze" }],
        },
      })

      # Workflow completed
      instance.add_or_update_item!({
        "item" => {
          "id" => "cti_workflow_1",
          "type" => "workflow",
          "workflow" => {
            "type" => "reasoning",
            "tasks" => [{ "id" => "task1", "description" => "Analyze" }],
            "summary" => { "duration" => 3 },
          },
        },
      })

      # Assistant message follows
      instance.add_or_update_item!({
        "item" => {
          "id" => "cti_assistant_1",
          "type" => "assistant_message",
          "content" => [{ "type" => "output_text", "text" => "Based on analysis..." }],
        },
      })

      expect(instance.items.size).to eq(1)
      expect(instance.items.first.workflow).not_to be_nil
      expect(instance.items.first.workflow.tasks.first["description"]).to eq("Analyze")
      expect(instance.items.first.workflow.summary["duration"]).to eq(3)
      expect(instance.items.first.content.first.text).to eq("Based on analysis...")
    end
  end
end
