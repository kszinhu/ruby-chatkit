# frozen_string_literal: true

RSpec.describe ChatKit::Request::Headers do
  describe ".conversation_header" do
    it "returns the correct conversation header" do
      expect(described_class.conversation_header).to eq({
        "Content-Type" => "application/json",
        "Accept" => "text/event-stream",
        "Cache-Control" => "no-cache",
      })
    end
  end

  describe ".sessions_header" do
    it "returns the correct sessions header" do
      expect(described_class.sessions_header).to eq({
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "OpenAI-Beta" => "chatkit_beta=v1",
      })
    end
  end

  describe "error handling for undefined endpoints" do
    it "raises NoMethodError for undefined endpoint" do
      expect do
        described_class.undefined_endpoint
      end.to raise_error(NoMethodError)
    end
  end
end
