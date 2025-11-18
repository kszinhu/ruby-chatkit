# frozen_string_literal: true

FactoryBot.define do
  factory :expires_after, class: "ChatKit::Session::ExpiresAfter" do
    anchor { "creation" }
    seconds { 600 }

    trait :short_expiry do
      seconds { 60 }
    end

    trait :long_expiry do
      seconds { 3600 }
    end

    trait :ten_minutes do
      seconds { 600 }
    end

    trait :one_hour do
      seconds { 3600 }
    end

    trait :one_day do
      seconds { 86_400 }
    end

    trait :last_activity_anchor do
      anchor { "last_activity" }
    end

    trait :creation_anchor do
      anchor { "creation" }
    end

    trait :custom_anchor do
      anchor { "custom_timestamp" }
    end

    initialize_with { new(anchor:, seconds:) }
  end
end
