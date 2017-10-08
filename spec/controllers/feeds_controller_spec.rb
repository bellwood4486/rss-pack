# frozen_string_literal: true

require 'rails_helper'

describe FeedsController, type: :controller do
  let(:login_user) { create(:user_with_pack) }

  before :each do
    session[:user_id] = login_user.id
  end

  describe 'GET #index' do
    context 'フィードがない場合' do
      it '@feedsは空配列になること' do
        get :index
        expect(assigns(:feeds)).to be_empty
      end

      it ':index テンプレートを表示すること' do
        get :index
        expect(response).to render_template :index
      end
    end

    context 'フィードが複数ある場合' do
      let(:other_user) { create(:user) }

      before :each do
        2.times { create(:feed, user: login_user) }
        1.times { create(:feed, user: other_user) }
      end

      it 'ログインユーザーに紐づくフィードのみを配列にまとめること' do
        get :index
        expect(assigns(:feeds).count).to eq 2
        expect(assigns(:feeds).all { |f| f.user == login_user }).to be_truthy
      end

      it ':index テンプレートを表示すること' do
        get :index
        expect(response).to render_template :index
      end
    end
  end

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
               content_type: 'dummy_type' }]
        )
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

  describe 'POST #create' do
    context '有効な属性の場合' do
      before :each do
        # :TODO Feedのさらに先のFetcherの挙動を差し替えないとテストできないのは、設計がよろしくないかも。
        allow(Feeds::Fetcher).to \
          receive(:fetch).and_return(etag: 'dummy', content: 'dummycontent')
      end

      it 'データベースに新しいフィードを保存すること' do
        expect {
          post :create, params: { feed: attributes_for(:feed) }
        }.to change(Feed, :count).by(1)
      end

      it 'feeds#indexにリダイレクトすること' do
        post :create, params: { feed: attributes_for(:feed) }
        expect(response).to redirect_to feeds_url
      end
    end

    context '無効な属性の場合' do
      it 'データベースに新しいユーザーを保存しないこと'
      it ':select テンプレートを再表示すること'
    end
  end
end
