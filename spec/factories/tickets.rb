FactoryBot.define do
  factory :ticket do
    subject { "Test Ticket" }
    description { "Test Description" }
    status { :open }
    priority { :normal }
    association :requester, factory: :user
    assignee { nil }
    category { "General" }
    closed_at { nil }
  end
end
