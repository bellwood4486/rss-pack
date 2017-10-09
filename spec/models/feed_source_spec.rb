require 'rails_helper'

describe FeedSource, type: :model do
  it '有効なファクトリを持つこと' do
    expect(build(:feed_source)).to be_valid
  end

  it 'URLがなければ無効な状態であること' do
    source = build(:feed_source, url: nil)
    source.valid?
    expect(source.errors[:url]).to include "can't be blank"
  end
end
