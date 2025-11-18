# frozen_string_literal: true

FactoryBot.define do
  factory :tracing, class: "ChatKit::Session::Workflow::Tracing" do
    enabled { true }

    trait :enabled do
      enabled { true }
    end

    trait :disabled do
      enabled { false }
    end

    trait :nil_enabled do
      enabled { nil }
    end

    trait :default_enabled do
      enabled { ChatKit::Session::Defaults::ENABLED }
    end

    initialize_with { new(enabled:) }
  end
end
