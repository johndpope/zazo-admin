require 'rails_helper'

RSpec.describe UsersController, type: :controller, authenticate_with_http_basic: true do
  describe 'GET #index' do
    let(:user) { create(:user) }
    
    describe 'search' do
      context 'by first_name' do
        let(:params) { { query: user.first_name } }
        specify do
          get :index, params
          expect(assigns(:users)).to eq([user])
        end
      end

      context 'by mobile_number' do
        let(:params) { { query: user.mobile_number.gsub('+', '') } }
        specify do
          get :index, params
          expect(assigns(:users)).to eq([user])
        end
      end
    end

    describe 'go to user' do
      context 'by id' do
        let(:params) { { user_id_or_mkey: user.id } }

        specify do
          get :index, params
          expect(response).to redirect_to(user)
        end
      end

      context 'by mkey' do
        let(:params) { { user_id_or_mkey: user.mkey } }

        specify do
          get :index, params
          expect(response).to redirect_to(user)
        end

        context 'when mkey converts to integer' do
          let!(:wrong_user) { create(:user, id: 1) }
          let!(:user) { create(:user, id: 2, mkey: '01GGDDAAaWtDUZvPMTHx') }

          specify do
            get :index, params
            expect(response).to redirect_to(user)
          end
        end
      end

      context 'when no user found' do
        let(:params) { { user_id_or_mkey: 'fooo' } }

        describe 'alert' do
          specify do
            get :index, params
            expect(flash[:alert]).to be_present
          end
        end
      end
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user) }
    subject { get :show, id: user.to_param }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #events' do
    let(:user) { create(:user) }
    subject { get :events, id: user.id }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
