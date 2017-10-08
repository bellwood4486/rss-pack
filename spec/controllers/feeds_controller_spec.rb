require 'rails_helper'

describe FeedsController, type: :controller do

  describe 'GET #discover' do
    it '@feed_source にFeedSourceクラスのインスタンスを割り当てること' do
      get :discover
      expect(assigns(:feed_source).class).to eq FeedSource
    end
  end

  describe 'GET #select' do
    context '有効な属性の場合' do
      before :each do
        allow(Feeds::Fetcher).to receive(:discover).and_return(
            [{ title: 'dummy title',
               url: 'http://dummy/url',
               content_type: 'dummy_type' }])
        get :select, params: { feed_source: attributes_for(:feed_source) }
      end

      let :feed do
        assigns(:feeds).first
      end

      it '@feeds にタイトルが含まれていること' do
        expect(feed.title).to eq 'dummy title'
      end

      it '@feeds にURLが含まれていること' do
        expect(feed.url).to eq 'http://dummy/url'
      end

      it '@feeds にコンテンツタイプが含まれていること' do
        expect(feed.content_type).to eq 'dummy_type'
      end

      it ':select テンプレートを表示すること' do
        expect(response).to render_template :select
      end
    end

    context '無効な属性の場合' do
      before :each do
        allow(Feeds::Fetcher).to receive(:discover).and_return([])
        get :select, params: { feed_source: attributes_for(:no_feed_source) }
      end

      it '@feeds にフィードが含まれていないこと' do
        expect(assigns(:feeds)).to be_empty
      end

      it ':discover テンプレートを再表示すること' do
        expect(response).to render_template :discover
      end
    end
  end
end
