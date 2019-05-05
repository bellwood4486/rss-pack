FactoryBot.define do
  factory :feed do
    sequence(:url) {|n| "http://example#{n}.com/feed" }
    sequence(:channel_title) {|n| "example#{n} blog" }
    sequence(:channel_url) {|n| "http://example#{n}.com" }
  end
end
