require 'rails_helper'

describe UsersController, type: :controller do

  describe 'GET #new' do
    it '@user に新しいユーザーを割り当てること' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it ':new テンプレートを表示すること' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context '有効な属性の場合' do
      it 'データベースに新しいユーザーを保存すること' do
        expect {
          post :create, params: { user: attributes_for(:user) }
        }.to change(User, :count).by(1)
      end
      it 'トップページにリダイレクトすること' do
        post :create, params: { user: attributes_for(:user) }
        expect(response).to redirect_to root_url
      end
      it '新しいユーザーはPackを1つ持っていること'
    end

    context '無効な属性の場合' do
      it 'データベースに新しいユーザーを保存しないこと' do
        expect {
          post :create, params: { user: attributes_for(:invalid_user) }
        }.not_to change(User, :count)
      end

      it ':new テンプレートを再表示すること' do
        post :create, params: { user: attributes_for(:invalid_user) }
        expect(response).to render_template :new
      end
    end

  end
end
