def rand_time(from, to = Time.zone.now)
  Time.zone.at(rand(from.to_f..to.to_f))
end

FactoryBot.define do
  factory :article do
    feed
    sequence(:title) {|n| "Article title#{n}" }
    sequence(:link) {|n| "https://example.com/articles/#{n}" }
    published_at { rand_time(3.years.ago) }
  end
end
