require "rails_helper"

RSpec.describe Subscription, type: :model do
  describe "#unread_articles" do
    it "有効なファクトリをもつこと" do
      expect(build(:subscription)).to be_valid
    end

    it "一つのパック内で、同じフィードに対する購読が複数するのは不正な状態とみなし、例外をスローすること" do
      pack = create(:pack)
      feed = create(:feed)
      create(:subscription, pack: pack, feed: feed)

      subscription = build(:subscription, pack: pack, feed: feed)
      expect { subscription.valid? }.to raise_error(ActiveModel::StrictValidationFailed, /はすでに存在します/)
    end

    context "フィードの情報取得が成功した場合" do
      let(:jan_1) { Time.zone.parse("2019/1/1 00:00:00") }
      let(:jan_2) { Time.zone.parse("2019/1/2 00:00:00") }
      let(:feed) do
        feed = create(:feed) do |f|
          f.articles.create!(attributes_for(:article, published_at: jan_1))
          f.articles.create!(attributes_for(:article, published_at: jan_2))
        end

        allow(feed).to receive(:fetch_and_save!)
        feed
      end

      it "フィード取得のエラー情報をクリアすること" do
        subscription = create(:subscription, feed: feed, message: "dummy", messaged_at: Time.zone.now)

        expect { subscription.unread_articles }.
          to change { subscription.message }.from(String).to(nil).
               and change { subscription.messaged_at }.from(ActiveSupport::TimeWithZone).to(nil)
      end

      context "未読記事の取得が初回の場合" do
        let(:subscription) { create(:subscription, feed: feed, read_timestamp: nil) }

        it "フィードの全ての記事を未読記事として返すこと" do
          expect(subscription.unread_articles.map(&:published_at)).to match_array [jan_1, jan_2]
        end

        it "取得記事の最新発行日時を更新すること" do
          subscription.unread_articles

          expect(subscription.read_timestamp).to eq jan_2
        end
      end

      context "前回取得時から未読記事がある場合" do
        let(:subscription) { create(:subscription, feed: feed, read_timestamp: jan_1) }

        it "前回取得した最新記事より後ののもを返すこと" do
          expect(subscription.unread_articles.map(&:published_at)).to match_array [jan_2]
        end

        it "取得記事の最新発行日時を更新すること" do
          subscription.unread_articles

          expect(subscription.read_timestamp).to eq jan_2
        end
      end

      context "前回取得時から未読記事がない場合" do
        let(:subscription) { create(:subscription, feed: feed, read_timestamp: jan_2) }

        it "空配列を返すこと" do
          expect(subscription.unread_articles).to match_array []
        end
      end
    end

    context "フィードの情報取得に失敗した場合" do
      let(:feed) do
        feed = create(:feed)
        allow(feed).to receive(:fetch_and_save!).and_raise(Feed::FeedError.new(error_detail))
        feed
      end
      let(:error_detail) { "error details" }

      it "フィード取得のエラー情報を設定すること" do
        subscription = create(:subscription, feed: feed, message: nil, messaged_at: nil)

        expect { subscription.unread_articles }.
          to change { subscription.message }.from(nil).to(String).
               and change { subscription.messaged_at }.from(nil).to(ActiveSupport::TimeWithZone)
      end

      it "エラーメッセージを含む疑似記事オブジェクトを返すこと" do
        subscription = create(:subscription, feed: feed)

        actual_articles = subscription.unread_articles

        expect(actual_articles.length).to eq 1
        expect(actual_articles[0].title).to a_string_starting_with "[RSSPACKからのお知らせ]"
        expect(actual_articles[0].link).to eq pack_subscription_url(subscription.pack, subscription)
        expect(actual_articles[0].summary).to eq error_detail
        expect(actual_articles[0].published_at).to be_instance_of ActiveSupport::TimeWithZone
      end
    end
  end
end
