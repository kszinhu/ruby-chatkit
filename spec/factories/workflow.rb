# frozen_string_literal: true

FactoryBot.define do
  factory :workflow, class: "ChatKit::Session::Workflow" do
    id { "wf_abc123" }
    state_variables { { "variable1" => "value1", "variable2" => "value2" } }
    tracing
    version { "1.0.0" }

    trait :minimal do
      state_variables { nil }
      version { nil }
    end

    trait :with_nil_state do
      state_variables { nil }
    end

    trait :with_empty_state do
      state_variables { {} }
    end

    trait :with_nil_version do
      version { nil }
    end

    trait :with_complex_state do
      state_variables do
        {
          "config" => { "timeout" => 30, "retries" => 3 },
          "user_input" => "Hello world",
          "flags" => %w[debug verbose],
        }
      end
    end

    initialize_with { new(id:, state_variables:, tracing: attributes_for(:tracing), version:) }
  end
end
