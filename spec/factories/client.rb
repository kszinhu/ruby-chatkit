# frozen_string_literal: true

FactoryBot.define do
  factory :client, class: "ChatKit::Client" do
    api_key { "test_api_key_123" }
    host { "https://test-api.openai.com" }

    trait :with_nil_api_key do
      api_key { nil }
    end

    trait :with_empty_api_key do
      api_key { "" }
    end

    trait :with_production_host do
      host { ChatKit::Client::OpenAI::HOST }
    end

    trait :with_custom_host do
      host { "https://custom-chatkit.example.com" }
    end

    trait :with_localhost do
      host { "http://localhost:3000" }
    end

    trait :with_config_defaults do
      transient do
        config_instance { build(:config) }
      end

      before(:build) do |_client, evaluator|
        allow(ChatKit).to receive(:configuration).and_return(evaluator.config_instance)
      end

      api_key { nil }
      host { nil }
    end

    initialize_with { new(api_key:, host:) }
  end
end
