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

    let(:pack) { build(:pack, rss_refreshed_at: Time.zone.now.ago(duration)) }
    subject { pack.fresh? }

    context '前回更新から59秒以下の場合' do
      let(:duration) { 59.seconds }
      it { is_expected.to be_truthy }
    end

    context '前回更新からちょうど60秒の場合' do
      let(:duration) { 60.seconds }
      it { is_expected.to be_truthy }
    end

    context '前回更新から61秒以上の場合' do
      let(:duration) { 61.seconds }
      it { is_expected.to be_falsey }
    end
  end
end
