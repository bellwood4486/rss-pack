FactoryGirl.define do
  factory :feed_source do
    url { Faker::Internet.url }
  end

  factory :no_feed_source, class: FeedSource do
    url 'http://localhost/nofeed'
  end
end
