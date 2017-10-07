require 'rails_helper'

describe Pack, type: :model do
  it '有効なファクトリを持つこと' do
    expect(build(:pack)).to be_valid
  end

  describe '#fresh?' do
    before :all do
      EasySettings.rss_fresh_duration = 60
      Timecop.freeze
    end

    after :all do
      Timecop.return
    end

    let :pack do
      build(:pack)
    end

    it '前回更新から1分(設置値)経ってなかったらtrueを返すこと' do
      pack.rss_refreshed_at = Time.zone.now.ago(59.seconds)
      expect(pack).to be_fresh
    end

    it '前回更新からちょうど1分(設置値)ならtrueを返すこと' do
      pack.rss_refreshed_at = Time.zone.now.ago(60.seconds)
      expect(pack).to be_fresh
    end

    it '前回更新から1分(設置値)以上経ってたらfalseを返すこと' do
      pack.rss_refreshed_at = Time.zone.now.ago(61.seconds)
      expect(pack).not_to be_fresh
    end
  end
end
