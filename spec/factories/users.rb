FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'secret'
    password_confirmation 'secret'

    factory :user_with_pack do
      after :build do |user|
        user.packs << build(:pack)
      end
    end

    factory :invalid_user do
      email nil
    end
  end
end
