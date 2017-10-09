FactoryGirl.define do
  factory :pack do
    user

    factory :pack_with_rss_content do
      rss_content 'dummycontent'
      rss_refreshed_at Time.zone.now
    end
  end
end
