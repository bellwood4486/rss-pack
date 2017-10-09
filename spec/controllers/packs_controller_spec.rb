require 'rails_helper'

describe PacksController, type: :controller do
  describe 'GET #rss' do
    context '存在するrss_tokenの場合' do
      let(:pack) { build_stubbed(:pack_with_rss_content) }

      before :each do
        allow(Pack).to receive(:find_by).and_return(pack)
        allow(pack).to receive(:refresh!)
      end

      it 'rss_tokenに対応するrss_contentを返すこと' do
        get :rss, params: { token: pack.rss_token }
        expect(response.body).to eq pack.rss_content
      end
    end

    context '存在しないrss_tokenの場合' do
      it 'RoutingErrorを投げること' do
        expect {
          get :rss, params: { token: 'unknowntoken' }
        }.to raise_error ActionController::RoutingError
      end
    end
  end
end
