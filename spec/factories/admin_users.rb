FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_token do
      api_token { SecureRandom.hex(32) }
    end
  end
end
