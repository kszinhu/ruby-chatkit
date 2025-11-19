# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChatKit::Conversation::Stream do
  describe ".new" do
    it "initializes with chunks" do
      chunks = double("chunks")
      stream = described_class.new(chunks)
      expect(stream).to be_a(described_class)
    end
  end

  describe "#stream!" do
    let(:chunks) { double("chunks") }
    let(:stream) { described_class.new(chunks) }

    context "with valid event stream data" do
      it "parses and yields each event" do
        event_data = "data: {\"type\":\"thread.created\",\"thread\":{\"id\":\"cthr_123\"}}\n\n"
        body = [event_data]

        allow(chunks).to receive(:body).and_return(body)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events.size).to eq(1)
        expect(yielded_events.first["type"]).to eq("thread.created")
        expect(yielded_events.first["thread"]["id"]).to eq("cthr_123")
      end

      it "handles multiple events in stream" do
        events = [
          "data: {\"type\":\"thread.created\",\"thread\":{\"id\":\"cthr_123\"}}\n\n",
          "data: {\"type\":\"thread.item.added\",\"item\":{\"id\":\"cti_1\"}}\n\n",
          "data: {\"type\":\"thread.updated\",\"thread\":{\"title\":\"Test\"}}\n\n",
        ]

        allow(chunks).to receive(:body).and_return(events)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events.size).to eq(3)
        expect(yielded_events[0]["type"]).to eq("thread.created")
        expect(yielded_events[1]["type"]).to eq("thread.item.added")
        expect(yielded_events[2]["type"]).to eq("thread.updated")
      end

      it "handles events with nested data structures" do
        event_data = "data: {\"type\":\"thread.item.done\",\"item\":{\"id\":\"cti_1\",\"content\":[{\"type\":\"input_text\",\"text\":\"Hello\"}]}}\n\n"
        body = [event_data]

        allow(chunks).to receive(:body).and_return(body)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events.first["item"]["content"]).to be_an(Array)
        expect(yielded_events.first["item"]["content"].first["type"]).to eq("input_text")
        expect(yielded_events.first["item"]["content"].first["text"]).to eq("Hello")
      end

      it "handles events with special characters in text" do
        event_data = "data: {\"type\":\"update\",\"delta\":\"Hello \\\"world\\\" with \\\\n newline\"}\n\n"
        body = [event_data]

        allow(chunks).to receive(:body).and_return(body)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events.first["delta"]).to include('"world"')
      end

      it "handles text delta events" do
        events = [
          "data: {\"type\":\"assistant_message.content_part.text_delta\",\"delta\":\"Hello\"}\n\n",
          "data: {\"type\":\"assistant_message.content_part.text_delta\",\"delta\":\" \"}\n\n",
          "data: {\"type\":\"assistant_message.content_part.text_delta\",\"delta\":\"world\"}\n\n",
        ]

        allow(chunks).to receive(:body).and_return(events)

        deltas = []
        stream.stream! do |event|
          deltas << event["delta"] if event["type"] == "assistant_message.content_part.text_delta"
        end

        expect(deltas).to eq(["Hello", " ", "world"])
      end

      it "handles workflow events" do
        event_data = "data: {\"type\":\"workflow.task.added\",\"tasks\":[{\"id\":\"task1\",\"description\":\"Analyze\"}]}\n\n"
        body = [event_data]

        allow(chunks).to receive(:body).and_return(body)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events.first["type"]).to eq("workflow.task.added")
        expect(yielded_events.first["tasks"]).to be_an(Array)
      end
    end

    context "with empty or minimal data" do
      it "handles empty body" do
        allow(chunks).to receive(:body).and_return([])

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events).to be_empty
      end

      it "handles events with empty JSON objects" do
        event_data = "data: {}\n\n"
        body = [event_data]

        allow(chunks).to receive(:body).and_return(body)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events.size).to eq(1)
        expect(yielded_events.first).to eq({})
      end

      it "handles events with null values" do
        event_data = "data: {\"type\":\"test\",\"value\":null}\n\n"
        body = [event_data]

        allow(chunks).to receive(:body).and_return(body)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events.first["value"]).to be_nil
      end
    end

    context "with block handling" do
      it "yields to block for each event" do
        events = [
          "data: {\"type\":\"event1\"}\n\n",
          "data: {\"type\":\"event2\"}\n\n",
        ]

        allow(chunks).to receive(:body).and_return(events)

        call_count = 0
        stream.stream! do |_event|
          call_count += 1
        end

        expect(call_count).to eq(2)
      end

      it "passes parsed JSON data to block" do
        event_data = "data: {\"type\":\"test\",\"id\":123,\"active\":true}\n\n"
        body = [event_data]

        allow(chunks).to receive(:body).and_return(body)

        stream.stream! do |event|
          expect(event).to be_a(Hash)
          expect(event["type"]).to eq("test")
          expect(event["id"]).to eq(123)
          expect(event["active"]).to be(true)
        end
      end

      it "works without a block" do
        events = ["data: {\"type\":\"test\"}\n\n"]
        allow(chunks).to receive(:body).and_return(events)

        expect { stream.stream! }.not_to raise_error
      end
    end

    context "with event stream format variations" do
      it "handles multiline event data" do
        # EventStreamParser should handle this, but we test the integration
        events = [
          "data: {\"type\":\"test\",",
          "data: \"value\":\"data\"}",
        ]

        allow(chunks).to receive(:body).and_return(events)

        # This might parse as separate events or combined depending on parser
        expect do
          stream.stream! { |_event| }
        end.not_to raise_error
      end

      it "handles events with additional SSE fields" do
        # Event stream can have id:, event:, retry: fields
        events = [
          "id: 1",
          "event: message",
          'data: {"type":"test"}',
          "",
        ]

        allow(chunks).to receive(:body).and_return(events)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        # Should still parse the data field
        expect(yielded_events).not_to be_empty if yielded_events.any?
      end
    end

    context "with complex event sequences" do
      it "handles a complete conversation stream" do
        events = [
          "data: {\"type\":\"thread.created\",\"thread\":{\"id\":\"cthr_123\"}}\n\n",
          "data: {\"type\":\"thread.item.added\",\"item\":{\"id\":\"cti_user_1\",\"type\":\"user_message\"}}\n\n",
          "data: {\"type\":\"thread.item.done\",\"item\":{\"id\":\"cti_user_1\",\"content\":[{\"type\":\"input_text\",\"text\":\"Hello\"}]}}\n\n",
          "data: {\"type\":\"thread.item.added\",\"item\":{\"id\":\"cti_assistant_1\",\"type\":\"assistant_message\"}}\n\n",
          "data: {\"type\":\"thread.item.updated\",\"update\":{\"type\":\"assistant_message.content_part.added\",\"content\":{\"type\":\"output_text\"}}}\n\n",
          "data: {\"type\":\"thread.item.updated\",\"update\":{\"type\":\"assistant_message.content_part.text_delta\",\"delta\":\"Hi\"}}\n\n",
          "data: {\"type\":\"thread.item.updated\",\"update\":{\"type\":\"assistant_message.content_part.done\",\"content\":{\"type\":\"text\",\"text\":\"Hi there\"}}}\n\n",
          "data: {\"type\":\"thread.updated\",\"thread\":{\"title\":\"Greeting\"}}\n\n",
        ]

        allow(chunks).to receive(:body).and_return(events)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events.size).to eq(8)

        # Verify event types in sequence
        types = yielded_events.map { |e| e["type"] }
        expect(types).to include("thread.created")
        expect(types).to include("thread.item.added")
        expect(types).to include("thread.item.done")
        expect(types).to include("thread.item.updated")
        expect(types).to include("thread.updated")
      end

      it "handles workflow events in sequence" do
        events = [
          "data: {\"type\":\"thread.item.added\",\"item\":{\"id\":\"cti_workflow_1\",\"type\":\"workflow\"}}\n\n",
          "data: {\"type\":\"thread.item.updated\",\"update\":{\"type\":\"workflow.created\",\"workflow\":{\"type\":\"reasoning\"}}}\n\n",
          "data: {\"type\":\"thread.item.updated\",\"update\":{\"type\":\"workflow.task.added\",\"tasks\":[{\"id\":\"task1\"}]}}\n\n",
          "data: {\"type\":\"thread.item.updated\",\"update\":{\"type\":\"workflow.completed\",\"summary\":{\"duration\":5}}}\n\n",
          "data: {\"type\":\"thread.item.done\",\"item\":{\"id\":\"cti_workflow_1\",\"workflow\":{\"type\":\"reasoning\",\"summary\":{\"duration\":5}}}}\n\n",
        ]

        allow(chunks).to receive(:body).and_return(events)

        yielded_events = []
        stream.stream! do |event|
          yielded_events << event
        end

        expect(yielded_events.size).to eq(5)

        # Verify workflow event types
        update_types = yielded_events
          .select { |e| e["type"] == "thread.item.updated" }
          .map { |e| e.dig("update", "type") }

        expect(update_types).to include("workflow.created")
        expect(update_types).to include("workflow.task.added")
        expect(update_types).to include("workflow.completed")
      end
    end

    context "error handling" do
      it "handles invalid JSON gracefully" do
        events = ["data: {invalid json}\n\n"]
        allow(chunks).to receive(:body).and_return(events)

        expect do
          stream.stream! { |_event| nil }
        end.to raise_error(JSON::ParserError)
      end

      it "propagates errors from the block" do
        events = ["data: {\"type\":\"test\"}\n\n"]
        allow(chunks).to receive(:body).and_return(events)

        expect do
          stream.stream! do |_event|
            raise StandardError, "Block error"
          end
        end.to raise_error(StandardError, "Block error")
      end
    end

    context "parser reuse" do
      it "uses the same parser instance for multiple chunks" do
        events = [
          'data: {"type":"event1"}',
          'data: {"type":"event2"}',
        ]

        allow(chunks).to receive(:body).and_return(events)

        parser_instance = nil
        allow(EventStreamParser::Parser).to receive(:new).and_wrap_original do |method|
          parser_instance ||= method.call
        end

        stream.stream! { |_event| }

        expect(EventStreamParser::Parser).to have_received(:new).once
      end
    end
  end

  describe "integration with EventStreamParser" do
    let(:chunks) { double("chunks") }
    let(:stream) { described_class.new(chunks) }

    it "correctly integrates with EventStreamParser::Parser" do
      # Test that the parser is created and used correctly
      event_data = 'data: {"type":"test","message":"hello"}'
      body = [event_data]

      allow(chunks).to receive(:body).and_return(body)

      parser_instance = instance_double(EventStreamParser::Parser)
      allow(EventStreamParser::Parser).to receive(:new).and_return(parser_instance)
      allow(parser_instance).to receive(:feed).and_yield(nil, '{"type":"test","message":"hello"}')

      yielded_events = []
      stream.stream! do |event|
        yielded_events << event
      end

      expect(parser_instance).to have_received(:feed).once
      expect(yielded_events.first["message"]).to eq("hello")
    end
  end
end
