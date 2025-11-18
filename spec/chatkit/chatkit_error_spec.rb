# frozen_string_literal: true

RSpec.describe ChatKit::ChatKitError do
  describe ".set_error" do
    let(:klass_name) { "TestClass" }
    let(:error_message) { "Test error message" }

    context "when creating a new error class" do
      before do
        # Ensure the error class doesn't exist before the test
        ChatKit.send(:remove_const, "TestClassError") if ChatKit.const_defined?("TestClassError")
      end

      after do
        # Clean up after the test
        ChatKit.send(:remove_const, "TestClassError") if ChatKit.const_defined?("TestClassError")
      end

      it "creates a new error class dynamically" do
        error_class = described_class.set_error(klass_name, error_message)

        expect(error_class).to be_a(Class)
        expect(error_class.ancestors).to include(ChatKit::Error)
        expect(ChatKit.const_defined?("TestClassError")).to be(true)
      end

      it "returns the correct error class name" do
        error_class = described_class.set_error(klass_name, error_message)

        expect(error_class.name).to eq("ChatKit::TestClassError")
      end

      it "creates an error instance with the default message" do
        error_class = described_class.set_error(klass_name, error_message)
        error_instance = error_class.new

        expect(error_instance).to be_a(ChatKit::Error)
        expect(error_instance.message).to eq(error_message)
      end

      it "allows overriding the default message" do
        error_class = described_class.set_error(klass_name, error_message)
        custom_message = "Custom error message"
        error_instance = error_class.new(custom_message)

        expect(error_instance.message).to eq(custom_message)
      end
    end

    context "when the error class already exists" do
      let(:existing_error_class) do
        # Create the error class first
        described_class.set_error(klass_name, error_message)
      end

      before do
        existing_error_class # Ensure it's created
      end

      after do
        # Clean up after the test
        ChatKit.send(:remove_const, "TestClassError") if ChatKit.const_defined?("TestClassError")
      end

      it "returns the existing error class instead of creating a new one" do
        first_call = existing_error_class
        second_call = described_class.set_error(klass_name, "Different message")

        expect(first_call).to be(second_call)
        expect(first_call.object_id).to eq(second_call.object_id)
      end

      it "does not modify the existing error class behavior" do
        existing_error_class
        original_instance = existing_error_class.new

        described_class.set_error(klass_name, "Different message")
        new_instance = existing_error_class.new

        expect(original_instance.message).to eq(new_instance.message)
        expect(original_instance.message).to eq(error_message)
      end
    end

    context "with different class names" do
      after do
        # Clean up multiple error classes
        %w[SessionError ClientError RequestError].each do |error_name|
          ChatKit.send(:remove_const, error_name) if ChatKit.const_defined?(error_name)
        end
      end

      it "creates different error classes for different names" do
        session_error = described_class.set_error("Session", "Session error")
        client_error = described_class.set_error("Client", "Client error")
        request_error = described_class.set_error("Request", "Request error")

        expect(session_error).not_to be(client_error)
        expect(client_error).not_to be(request_error)
        expect(session_error).not_to be(request_error)

        expect(session_error.name).to eq("ChatKit::SessionError")
        expect(client_error.name).to eq("ChatKit::ClientError")
        expect(request_error.name).to eq("ChatKit::RequestError")
      end

      it "creates error instances with their respective messages" do
        session_error = described_class.set_error("Session", "Session failed")
        client_error = described_class.set_error("Client", "Client failed")

        session_instance = session_error.new
        client_instance = client_error.new

        expect(session_instance.message).to eq("Session failed")
        expect(client_instance.message).to eq("Client failed")
      end
    end

    context "error class inheritance" do
      after do
        ChatKit.send(:remove_const, "InheritanceTestError") if ChatKit.const_defined?("InheritanceTestError")
      end

      it "inherits from ChatKit::Error" do
        error_class = described_class.set_error("InheritanceTest", "test")
        error_instance = error_class.new

        expect(error_instance).to be_a(ChatKit::Error)
        expect(error_instance).to be_a(StandardError)
      end

      it "can be rescued as ChatKit::Error" do
        error_class = described_class.set_error("InheritanceTest", "test")

        expect do
          raise error_class, "test error"
        end.to raise_error(ChatKit::Error)
      end

      it "can be rescued as StandardError" do
        error_class = described_class.set_error("InheritanceTest", "test")

        expect do
          raise error_class, "test error"
        end.to raise_error(StandardError)
      end
    end
  end
end
