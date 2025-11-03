require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  it "inherits from ActiveJob::Base" do
    expect(described_class.superclass).to eq(ActiveJob::Base)
  end

  it "allows defining jobs that run via ApplicationJob" do
    klass = Class.new(ApplicationJob) do
      def perform(*); end
    end

    expect { klass.perform_now }.not_to raise_error
  end
end
