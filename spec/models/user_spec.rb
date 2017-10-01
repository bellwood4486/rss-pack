require 'rails_helper'

describe User, type: :model do
  it 'メールアドレス、パスワード(確認用も)があれば有効な状態であること' do
    user = User.new(email: 'test@example.com',
                    password: 'secret',
                    password_confirmation: 'secret')
    expect(user).to be_valid
  end

  it 'メールアドレスがなければ無効な状態であること' do
    user = User.new(email: nil)
    user.valid?
    expect(user.errors[:email]).to include "can't be blank"
  end

  it 'パスワードがなければ無効な状態であること' do
    user = User.new(password: nil)
    user.valid?
    expect(user.errors[:password]).to include "can't be blank"
  end

  it 'パスワードと確認用パスワードが一致しなければ不正な状態であること' do
    user = User.new(password: 'secret',
                    password_confirmation: '12345')
    user.valid?
    expect(user.errors[:password_confirmation]).to include "doesn't match Password"
  end

  it '重複したメールアドレスは無効な状態であること' do
    User.create(email: 'test@example.com',
                password: 'secret',
                password_confirmation: 'secret')
    user = User.new(email: 'test@example.com',
                    password: 'secret',
                    password_confirmation: 'secret')
    user.valid?
    expect(user.errors[:email]).to include "has already been taken"
  end

  it '保存されるメールアドレスは小文字になっていること' do
    user = User.create(email: 'TEST@EXAMPLE.COM',
                password: 'secret',
                password_confirmation: 'secret')
    user.reload
    expect(user.email).to eq 'test@example.com'
  end
end
