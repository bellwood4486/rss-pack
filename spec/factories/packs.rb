FactoryBot.define do
  factory :pack do
    user
    sequence(:name) {|n| "パック#{n}" }

    trait :with_subscription do
      after(:create) do |pack|
        create(:subscription, pack: pack)
      end
    end
  end
end
