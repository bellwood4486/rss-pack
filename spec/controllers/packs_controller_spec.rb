require 'rails_helper'

describe PacksController, type: :controller do
  describe 'GET #rss' do
    context '存在するrss_tokenの場合' do
      let(:pack) { build_stubbed(:pack, rss_token: 'dummytoken') }

      before :each do
        allow(Pack).to receive(:find_by).and_return(pack)
        allow(pack).to receive(:refresh!)
        allow(pack).to receive(:rss_content).and_return('dummycontent')
      end

      it 'rss_tokenに対応するrss_contentを返すこと' do
        get :rss, params: { token: 'dummytoken' }
        expect(response.body).to eq 'dummycontent'
      end
    end

    context '存在しないrss_tokenの場合' do
      it '404を返すこと'
    end
  end
end
