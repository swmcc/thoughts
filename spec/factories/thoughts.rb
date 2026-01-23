FactoryBot.define do
  factory :thought do
    content { "This is a thought" }
    tags { [] }
    view_count { 0 }

    trait :with_tags do
      tags { [ "rails", "ruby" ] }
    end

    trait :popular do
      view_count { 100 }
    end

    trait :long_content do
      content { "A" * 140 }
    end
  end
end
