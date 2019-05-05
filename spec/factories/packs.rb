FactoryBot.define do
  factory :pack do
    user
    sequence(:name) {|n| "パック#{n}" }
    sequence(:rss_content) {|n| "RSSコンテンツ#{n}" }
    rss_created_at { Faker::Date.between(1.year.ago, Time.current) }

    trait :with_subscription do
      after(:create) do |pack|
        create(:subscription, pack: pack)
      end
    end
  end
end
