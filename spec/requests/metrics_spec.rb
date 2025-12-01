require 'rails_helper'

RSpec.describe MetricsController, type: :request do
  let(:user) { create(:user, role: :user) }
  let(:admin) { create(:user, role: :sysadmin) }

  describe 'GET /metrics/user' do
    context 'when user is authenticated' do
      before { sign_in user }

      it 'returns a successful response' do
  get summary_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns completion data' do
  get summary_path
        expect(assigns(:completion_data)).to be_a(Hash)
        expect(assigns(:completion_data)).to have_key(:labels)
        expect(assigns(:completion_data)).to have_key(:data)
      end

      it 'assigns ticket counts' do
  get summary_path
        expect(assigns(:open_tickets_count)).to be_a(Integer)
        expect(assigns(:resolved_tickets_count)).to be_a(Integer)
        expect(assigns(:total_assigned)).to be_a(Integer)
      end

      it 'renders the user_metrics template' do
  get summary_path
        expect(response).to render_template(:user_metrics)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to login' do
  get summary_path
        expect(response).to redirect_to(/login|auth/)
      end
    end
  end

  describe 'GET /metrics/admin' do
    context 'when user is admin' do
      before { sign_in admin }

      it 'returns a successful response' do
        get admin_dashboard_path
        expect(response).to have_http_status(:success)
      end

      it 'assigns metrics data' do
        get admin_dashboard_path
        expect(assigns(:tickets_by_category)).to be_a(Hash)
        expect(assigns(:average_resolution_time)).to be_a(Numeric)
        expect(assigns(:total_tickets)).to be_a(Integer)
        expect(assigns(:resolved_count)).to be_a(Integer)
        expect(assigns(:open_count)).to be_a(Integer)
      end

      it 'renders the admin_dashboard template' do
        get admin_dashboard_path
        expect(response).to render_template(:admin_dashboard)
      end
    end

    context 'when user is not admin' do
      before { sign_in user }

      it 'denies access (Pundit authorization)' do
        expect { get admin_dashboard_path }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to login' do
        get admin_dashboard_path
        expect(response).to redirect_to(/login|auth/)
      end
    end
  end
end
