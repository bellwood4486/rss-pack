require "rails_helper"

RSpec.describe Subscription, type: :model do
  def tzp(time_as_string)
    Time.zone.parse(time_as_string)
  end

  describe "unread_articles" do
    context "フィードの情報取得が成功した場合" do
      let(:subscription) { create(:subscription, feed: feed) }

      let(:feed) {
        feed = create(:feed) do |f|
          f.articles.create!(attributes_for(:article, published_at: tzp("2019/1/1 00:00:00")))
          f.articles.create!(attributes_for(:article, published_at: tzp("2019/1/2 00:00:00")))
        end

        allow(feed).to receive(:fetch_and_save!)
        feed
      }

      it "フィード取得のエラー情報をクリアすること" do
        subscription.update!(message: "dummy", messaged_at: Time.zone.now)

        subscription.unread_articles

        expect(subscription.message).to be_nil
        expect(subscription.messaged_at).to be_nil
      end

      context "未読記事の取得が初回の場合" do
        before do
          subscription.update!(read_timestamp: nil)
        end

        it "フィードの全ての記事を未読記事として返すこと" do
          expect(subscription.unread_articles.map(&:published_at)).to match_array [tzp("2019/1/1 00:00:00"), tzp("2019/1/2 00:00:00")]
        end

        it "取得記事の最新発行日時を更新すること" do
          subscription.unread_articles

          expect(subscription.read_timestamp).to eq tzp("2019/1/2 00:00:00")
        end
      end

      context "前回取得時から未読記事がある場合" do
        before do
          subscription.update!(read_timestamp: tzp("2019/1/1 00:00:00"))
        end

        it "前回取得した最新記事より後ののもを返すこと" do
          expect(subscription.unread_articles.map(&:published_at)).to match_array [tzp("2019/1/2 00:00:00")]
        end

        it "取得記事の最新発行日時を更新すること" do
          subscription.unread_articles

          expect(subscription.read_timestamp).to eq tzp("2019/1/2 00:00:00")
        end
      end

      context "前回取得時から未読記事がない場合" do
        before do
          subscription.update!(read_timestamp: tzp("2019/1/2 00:00:00"))
        end

        it "空配列を返すこと" do
          expect(subscription.unread_articles).to match_array []
        end
      end
    end

    context "フィードの情報取得に失敗した場合" do
      let(:subscription) { create(:subscription, feed: feed) }

      let(:feed) do
        feed = create(:feed)
        allow(feed).to receive(:fetch_and_save!).and_raise(Feed::FeedError.new("error details"))
        feed
      end

      it "フィード取得のエラー情報を設定すること" do
        subscription.unread_articles

        expect(subscription.message).not_to be_nil
        expect(subscription.messaged_at).not_to be_nil
      end

      it "エラーメッセージを含む疑似記事オブジェクトを返すこと" do
        actual_articles = subscription.unread_articles

        expect(actual_articles.length).to eq 1
        expect(actual_articles[0].title).to start_with "[RSSPACKからのお知らせ]"
        expect(actual_articles[0].link).to eq pack_subscription_url(subscription.pack, subscription)
        expect(actual_articles[0].summary).to eq "error details"
        expect(actual_articles[0].published_at).not_to be_nil
      end
    end
  end
end
