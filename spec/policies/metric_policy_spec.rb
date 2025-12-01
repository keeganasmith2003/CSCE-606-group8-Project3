require 'rails_helper'

RSpec.describe MetricPolicy, type: :policy do
  let(:user) { User.new(role: :user) }
  let(:admin) { User.new(role: :sysadmin) }

  describe 'user_metrics?' do
    subject { MetricPolicy.new(user, :metric).user_metrics? }

    context 'when user is authenticated' do
      it { is_expected.to be(true) }
    end

    context 'when user is nil' do
      let(:user) { nil }
      subject { MetricPolicy.new(user, :metric).user_metrics? }

      it { is_expected.to be(false) }
    end
  end

  describe 'admin_dashboard?' do
    context 'when user is admin' do
      subject { MetricPolicy.new(admin, :metric).admin_dashboard? }

      it { is_expected.to be(true) }
    end

    context 'when user is not admin' do
      subject { MetricPolicy.new(user, :metric).admin_dashboard? }

      it { is_expected.to be(false) }
    end

    context 'when user is nil' do
      subject { MetricPolicy.new(nil, :metric).admin_dashboard? }

      it { is_expected.to be(false) }
    end
  end
end
