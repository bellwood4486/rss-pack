FactoryBot.define do
  factory :article do
    feed
    sequence(:title) {|n| "Article title#{n}" }
    sequence(:link) {|n| "https://example.com/articles/#{n}" }
    sequence(:summary) {|n| "summary#{n}" }
    published_at { Faker::Date.between(1.year.ago, Time.current) }
  end
end
