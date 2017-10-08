FactoryGirl.define do
  factory :feed do
    url { Faker::Internet.url }
    title { Faker::App.name }
    content_type 'application/rss'
    content 'dummycontent'
    refreshed_at Time.zone.now
    association :user
  end
end
