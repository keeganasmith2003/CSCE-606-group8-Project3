FactoryBot.define do
  factory :ticket do
    subject { "Test Ticket" }
    description { "Test Description" }
    status { :open }
    priority { :medium }
    association :requester, factory: :user
    assignee { nil }
    category { Ticket::CATEGORY_OPTIONS.first }
    closed_at { nil }
  end
end
