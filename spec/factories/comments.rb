FactoryBot.define do
  factory :comment do
    association :ticket
    association :author, factory: :user
    body { "This is a comment." }
    visibility { :public }
  end
end
