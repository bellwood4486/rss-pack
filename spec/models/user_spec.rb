require 'rails_helper'

describe User, type: :model do
  it '有効なファクトリを持つこと' do
    expect(build(:user)).to be_valid
  end

  it 'メールアドレスがなければ無効な状態であること' do
    user = build(:user, email: nil)
    user.valid?
    expect(user.errors[:email]).to include "can't be blank"
  end

  it 'パスワードがなければ無効な状態であること' do
    user = build(:user, password: nil)
    user.valid?
    expect(user.errors[:password]).to include "can't be blank"
  end

  it 'パスワードと確認用パスワードが一致しなければ不正な状態であること' do
    user = build(:user,
                 password: 'secret',
                 password_confirmation: '12345')
    user.valid?
    expect(user.errors[:password_confirmation]).to include "doesn't match Password"
  end

  it '重複したメールアドレスは無効な状態であること' do
    create(:user, email: 'test@example.com')
    user = build(:user, email: 'test@example.com')
    user.valid?
    expect(user.errors[:email]).to include "has already been taken"
  end

  it '保存されるメールアドレスは小文字になっていること' do
    user = create(:user, email: 'TEST@EXAMPLE.COM')
    user.reload
    expect(user.email).to eq 'test@example.com'
  end
end
