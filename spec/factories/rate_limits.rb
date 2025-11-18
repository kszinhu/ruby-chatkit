# frozen_string_literal: true

FactoryBot.define do
  factory :rate_limits, class: "ChatKit::Session::RateLimits" do
    max_requests_per_1_minute { 20 }

    trait :default_limit do
      max_requests_per_1_minute { ChatKit::Session::RateLimits::Defaults::MAX_REQUESTS_PER_1_MINUTE }
    end

    trait :no_limit do
      max_requests_per_1_minute { nil }
    end

    trait :low_limit do
      max_requests_per_1_minute { 5 }
    end

    trait :high_limit do
      max_requests_per_1_minute { 100 }
    end

    trait :zero_limit do
      max_requests_per_1_minute { 0 }
    end

    initialize_with { new(max_requests_per_1_minute:) }
  end
end
