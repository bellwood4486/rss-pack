require "rails_helper"

RSpec.describe Feed, type: :model do
  describe "fetch" do
    context "まだ一度もフェッチしたことがない場合" do
      it "フィードの取得を実行すること" do
        feed = create(:feed, fetched_at: nil)
        expect(Feeds::Fetcher).to receive(:fetch!).and_return({ modified?: false })

        feed.fetch
      end
    end

    context "フェッチされたことがあり、かつ、フェッチ間隔が経過していた場合" do
      it "フィードの取得を実行すること" do
        feed = create(:feed, fetched_at: Time.zone.now)
        stub_const("Feed::FETCH_INTERVAL", 10)

        travel_to(11.seconds.since(feed.fetched_at)) do
          expect(Feeds::Fetcher).to receive(:fetch!).and_return({ modified?: false })
          feed.fetch
        end
      end
    end

    context "フェッチされたことがあり、かつ、フェッチ間隔が経過していない場合" do
      it "フィードの取得を実行しないこと" do
        feed = create(:feed, fetched_at: Time.zone.now)
        stub_const("Feed::FETCH_INTERVAL", 10)

        travel_to(9.seconds.since(feed.fetched_at)) do
          expect(Feeds::Fetcher).not_to receive(:fetch!)
          feed.fetch
        end
      end
    end

    context "フィードの取得に成功した場合" do
      it "フィードの取得日時を更新すること" do
        feed = create(:feed)
        allow(Feeds::Fetcher).to receive(:fetch!).and_return({ modified?: false })

        expect { feed.fetch }.to change(feed, :fetched_at)
      end

      context "フィードに更新がなかった場合" do
        it "フィードのコンテンツを更新しないこと" do
          feed = create(:feed)
          allow(Feeds::Fetcher).to receive(:fetch!).and_return({ modified?: false })

          # 代表してチャネルタイトルのみチェックする
          expect { feed.fetch }.not_to change(feed, :channel_title)
        end
      end
    end

    context "フィードの取得に失敗した場合" do
      it "例外をスローすること" do
        feed = create(:feed)
        allow(Feeds::Fetcher).to receive(:fetch!).and_raise(SocketError)

        expect { feed.fetch }.to raise_error(Feed::FeedError)
      end
    end
  end

  describe "fetch_and_save!" do
    context "DBへの保存に失敗した場合" do
      it "例外をスローすること" do
        feed = create(:feed)
        allow(feed).to receive(:fetch)
        allow(feed).to receive(:save!).and_raise(ActiveRecord::ActiveRecordError)

        expect { feed.fetch_and_save! }.to raise_error(Feed::FeedError)
      end
    end
  end
end
