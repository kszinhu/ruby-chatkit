# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChatKit::Conversation::Response do
  describe "#parse!" do
    let(:response) { described_class.new }

    context "with thread.created event" do
      it "creates the thread with metadata" do
        event = {
          "type" => "thread.created",
          "thread" => {
            "id" => "cthr_123",
            "created_at" => "2025-11-11T11:32:33.784959",
            "status" => { "type" => "active" },
            "metadata" => {},
          },
        }

        response.parse!(event)

        expect(response.thread.id).to eq("cthr_123")
        expect(response.thread.created_at).to eq("2025-11-11T11:32:33.784959")
        expect(response.thread.status).to eq({ "type" => "active" })
      end
    end

    context "with thread.updated event" do
      it "updates the thread title" do
        response.parse!({
          "type" => "thread.created",
          "thread" => { "id" => "cthr_123" },
        })

        response.parse!({
          "type" => "thread.updated",
          "thread" => { "title" => "Warm Welcome Conversation" },
        })

        expect(response.thread.title).to eq("Warm Welcome Conversation")
      end
    end

    context "with thread.item.done event for user message" do
      it "adds a user message item" do
        event = {
          "type" => "thread.item.done",
          "item" => {
            "id" => "cti_user_1",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-11T11:32:33.866014",
            "type" => "user_message",
            "content" => [
              { "type" => "input_text", "text" => "bonjour" },
            ],
            "attachments" => [],
            "quoted_text" => "",
            "inference_options" => {},
          },
        }

        response.parse!(event)

        expect(response.thread.items.size).to eq(1)

        item = response.thread.items.first
        expect(item.id).to eq("cti_user_1")
        expect(item.content.size).to eq(1)
        expect(item.content.first.type).to eq("input_text")
        expect(item.content.first.text).to eq("bonjour")
      end
    end

    context "with workflow item events" do
      it "creates and updates a workflow item" do
        # Create workflow item
        response.parse!({
          "type" => "thread.item.added",
          "item" => {
            "id" => "cti_workflow_1",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-11T11:32:35.942396Z",
            "type" => "workflow",
            "workflow" => {
              "type" => "reasoning",
              "tasks" => [],
              "expanded" => false,
            },
            "response_items" => [],
          },
        })

        item = response.thread.items.first
        expect(item.id).to eq("cti_workflow_1")
        expect(item.workflow).not_to be_nil
        expect(item.workflow.type).to eq("reasoning")
        expect(item.workflow.summary).to be_nil

        # Finalize workflow item
        response.parse!({
          "type" => "thread.item.done",
          "item" => {
            "id" => "cti_workflow_1",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-11T11:32:35.942396Z",
            "type" => "workflow",
            "workflow" => {
              "type" => "reasoning",
              "tasks" => [],
              "summary" => { "duration" => 4 },
              "expanded" => false,
            },
            "response_items" => [],
          },
        })

        expect(response.thread.items.size).to eq(1)
        expect(item.workflow.summary).to eq({ "duration" => 4 })
      end
    end

    context "with assistant message streaming events" do
      before do
        # Create assistant message item
        response.parse!({
          "type" => "thread.item.added",
          "item" => {
            "id" => "cti_assistant_1",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-11T11:32:40.759544Z",
            "type" => "assistant_message",
            "content" => [],
          },
        })
      end

      it "adds content part" do
        response.parse!({
          "type" => "thread.item.updated",
          "item_id" => "cti_assistant_1",
          "update" => {
            "type" => "assistant_message.content_part.added",
            "content_index" => 0,
            "content" => {
              "annotations" => [],
              "text" => "",
              "type" => "output_text",
            },
          },
        })

        item = response.thread.items.first
        expect(item.content.size).to eq(1)
        expect(item.content.first.type).to eq("output_text")
        expect(item.content.first.text).to eq("")
      end

      it "streams text deltas and builds final text" do
        # Add content part
        response.parse!({
          "type" => "thread.item.updated",
          "item_id" => "cti_assistant_1",
          "update" => {
            "type" => "assistant_message.content_part.added",
            "content_index" => 0,
            "content" => { "type" => "output_text", "text" => "" },
          },
        })

        # Stream deltas
        deltas = ["Bonjour", " !", " Comment", " puis", "-je", " vous", " aider", " ?"]
        deltas.each do |delta|
          response.parse!({
            "type" => "thread.item.updated",
            "item_id" => "cti_assistant_1",
            "update" => {
              "type" => "assistant_message.content_part.text_delta",
              "content_index" => 0,
              "delta" => delta,
            },
          })
        end

        item = response.thread.items.first
        expect(item.delta).to eq(deltas)
        expect(item.content.first.text).to eq("Bonjour ! Comment puis-je vous aider ?")
      end

      it "finalizes content with content_part.done" do
        final_text = "Bonjour ! Comment puis-je vous aider aujourd'hui ?"

        # Add content part
        response.parse!({
          "type" => "thread.item.updated",
          "item_id" => "cti_assistant_1",
          "update" => {
            "type" => "assistant_message.content_part.added",
            "content_index" => 0,
            "content" => { "type" => "output_text", "text" => "" },
          },
        })

        # Stream some deltas
        ["Bonjour", " !", " Comment"].each do |delta|
          response.parse!({
            "type" => "thread.item.updated",
            "item_id" => "cti_assistant_1",
            "update" => {
              "type" => "assistant_message.content_part.text_delta",
              "content_index" => 0,
              "delta" => delta,
            },
          })
        end

        # Finalize
        response.parse!({
          "type" => "thread.item.updated",
          "item_id" => "cti_assistant_1",
          "update" => {
            "type" => "assistant_message.content_part.done",
            "content_index" => 0,
            "content" => {
              "annotations" => [],
              "text" => final_text,
              "type" => "output_text",
            },
          },
        })

        item = response.thread.items.first
        expect(item.content.first.text).to eq(final_text)
      end
    end

    context "with complete streaming sequence" do
      it "processes all events correctly" do
        # 1. Create thread
        response.parse!({
          "type" => "thread.created",
          "thread" => {
            "id" => "cthr_123",
            "created_at" => "2025-11-11T11:32:33.784959",
            "status" => { "type" => "active" },
          },
        })

        # 2. Add user message
        response.parse!({
          "type" => "thread.item.done",
          "item" => {
            "id" => "cti_user",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-11T11:32:33.866014",
            "type" => "user_message",
            "content" => [{ "type" => "input_text", "text" => "bonjour" }],
          },
        })

        # 3. Add workflow item
        response.parse!({
          "type" => "thread.item.added",
          "item" => {
            "id" => "cti_workflow",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-11T11:32:35.942396Z",
            "type" => "workflow",
            "workflow" => { "type" => "reasoning", "tasks" => [] },
          },
        })

        # 4. Finalize workflow
        response.parse!({
          "type" => "thread.item.done",
          "item" => {
            "id" => "cti_workflow",
            "workflow" => { "summary" => { "duration" => 4 } },
          },
        })

        # 5. Add assistant message
        response.parse!({
          "type" => "thread.item.added",
          "item" => {
            "id" => "cti_assistant",
            "thread_id" => "cthr_123",
            "created_at" => "2025-11-11T11:32:40.759544Z",
            "type" => "assistant_message",
            "content" => [],
          },
        })

        # 6. Add content part
        response.parse!({
          "type" => "thread.item.updated",
          "item_id" => "cti_assistant",
          "update" => {
            "type" => "assistant_message.content_part.added",
            "content_index" => 0,
            "content" => { "type" => "output_text", "text" => "" },
          },
        })

        # 7. Stream deltas
        ["Hi", " there", "!"].each do |delta|
          response.parse!({
            "type" => "thread.item.updated",
            "item_id" => "cti_assistant",
            "update" => {
              "type" => "assistant_message.content_part.text_delta",
              "content_index" => 0,
              "delta" => delta,
            },
          })
        end

        # 8. Update thread title
        response.parse!({
          "type" => "thread.updated",
          "thread" => { "title" => "Warm Welcome" },
        })

        # 9. Finalize content
        response.parse!({
          "type" => "thread.item.updated",
          "item_id" => "cti_assistant",
          "update" => {
            "type" => "assistant_message.content_part.done",
            "content_index" => 0,
            "content" => { "type" => "output_text", "text" => "Hi there!" },
          },
        })

        # 10. Finalize item
        response.parse!({
          "type" => "thread.item.done",
          "item" => {
            "id" => "cti_assistant",
            "type" => "assistant_message",
            "content" => [{ "type" => "output_text", "text" => "Hi there!" }],
          },
        })

        # Verify final state
        expect(response.thread.id).to eq("cthr_123")
        expect(response.thread.title).to eq("Warm Welcome")
        expect(response.thread.items.size).to eq(1)

        conversation_item = response.thread.items.first

        # Should have both user input and assistant output in content
        expect(conversation_item.content.size).to eq(2)

        user_content = conversation_item.content.find { |c| c.type == "input_text" }
        expect(user_content.text).to eq("bonjour")

        assistant_content = conversation_item.content.find { |c| c.type == "output_text" }
        expect(assistant_content.text).to eq("Hi there!")

        # Should have workflow data
        expect(conversation_item.workflow).not_to be_nil
        expect(conversation_item.workflow.summary).to eq({ "duration" => 4 })

        # Should have deltas from streaming
        expect(conversation_item.delta).to eq(["Hi", " there", "!"])
      end
    end
  end
end
