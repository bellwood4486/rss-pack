FactoryBot.define do
  factory :subscription do
    pack
    feed
    sequence(:message) {|n| "メッセージ#{n}" }
    read_timestamp { Faker::Date.between(1.year.ago, Time.current) }
    messaged_at { Faker::Date.between(1.year.ago, Time.current) }
  end
end
