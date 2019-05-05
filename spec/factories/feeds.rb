FactoryBot.define do
  factory :feed do
    sequence(:url) {|n| "http://example#{n}.com/feed" }
    sequence(:channel_title) {|n| "example#{n} blog" }
    sequence(:channel_url) {|n| "http://example#{n}.com" }

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
