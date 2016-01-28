FactoryGirl.define do
  factory :connection do
    association :creator, factory: :user
    association :target, factory: :user

    after(:build) do |conn|
      conn.ckey = "#{conn.creator.id}_#{conn.target.id}_#{Faker::Lorem.characters(20)}"
    end

    trait :established do
      status :established
    end

    factory :established_connection, traits: [:established]
  end
end
