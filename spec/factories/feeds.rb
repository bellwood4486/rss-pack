FactoryBot.define do
  factory :feed do
    sequence(:url) {|n| "http://example#{n}.com/feed" }
    sequence(:etag) {|n| "etag#{n}" }
    sequence(:channel_title) {|n| "example#{n} blog" }
    sequence(:channel_url) {|n| "http://example#{n}.com" }
    sequence(:channel_description) {|n| "This is description#{n}." }
    fetched_at { Faker::Date.between(1.year.ago, Time.current) }

    trait :with_articles do
      transient do
        count { 1 }
      end

      after(:build) do |feed, evaluator|
        build_list(:article, evaluator.count, feed: feed)
      end
    end
  end
end
