require "rails_helper"

RSpec.describe Feed, type: :model do
  it "有効なファクトリをもつこと" do
    expect(build(:feed)).to be_valid
  end

  it "フィードURLがなければ無効な状態を示す例外をスローすること" do
    feed = build(:feed, url: nil)
    expect { feed.valid? }.to raise_error(ActiveModel::StrictValidationFailed, /を入力してください/)
  end

  it "チャネルタイトルがなければ無効な状態を示す例外をスローすること" do
    feed = build(:feed, channel_title: nil)
    expect { feed.valid? }.to raise_error(ActiveModel::StrictValidationFailed, /を入力してください/)
  end

  describe "#fetch" do
    context "まだ一度もフェッチしたことがない場合" do
      let(:feed) { create(:feed, fetched_at: nil) }

      it "フィードの取得を実行すること" do
        expect(Feeds::Fetcher).to receive(:fetch!).and_return({ modified?: false })
        feed.fetch
      end
    end

    context "フェッチされたことがあり、かつ、フェッチ間隔が経過していた場合" do
      let(:feed) { create(:feed, fetched_at: Time.zone.now) }

      it "フィードの取得を実行すること" do
        stub_const("Feed::FETCH_INTERVAL", 10)

        travel_to(11.seconds.since(feed.fetched_at)) do
          expect(Feeds::Fetcher).to receive(:fetch!).and_return({ modified?: false })
          feed.fetch
        end
      end
    end

    context "フェッチされたことがあり、かつ、フェッチ間隔が経過していない場合" do
      let(:feed) { create(:feed, fetched_at: Time.zone.now) }

      it "フィードの取得を実行しないこと" do
        stub_const("Feed::FETCH_INTERVAL", 10)

        travel_to(9.seconds.since(feed.fetched_at)) do
          expect(Feeds::Fetcher).not_to receive(:fetch!)
          feed.fetch
        end
      end
    end

    context "フィードの取得に成功した場合" do
      let(:feed) { create(:feed) }

      it "フィードの取得日時を更新すること" do
        allow(Feeds::Fetcher).to receive(:fetch!).and_return({ modified?: false })
        expect { feed.fetch }.to change { feed.fetched_at }
      end

      context "フィードに更新がなかった場合" do
        let(:feed) { create(:feed) }

        it "フィードのコンテンツを更新しないこと" do
          allow(Feeds::Fetcher).to receive(:fetch!).and_return({ modified?: false })
          expect { feed.fetch }.not_to change { feed.channel_title }
        end
      end
    end

    context "フィードの取得に失敗した場合" do
      let(:feed) { create(:feed) }

      it "例外をスローすること" do
        allow(Feeds::Fetcher).to receive(:fetch!).and_raise(SocketError)
        expect { feed.fetch }.to raise_error(Feed::FeedError)
      end

      it "OpenSSL::SSLErrorがスローされたらFeedErrorをスローすること" do
        allow(Feeds::Fetcher).to receive(:fetch!).and_raise(OpenSSL::OpenSSLError)
        expect { feed.fetch }.to raise_error(Feed::FeedError)
      end
    end
  end

  describe "#fetch_and_save!" do
    context "DBへの保存に失敗した場合" do
      let(:feed) { create(:feed) }

      it "例外をスローすること" do
        allow(feed).to receive(:fetch)
        allow(feed).to receive(:save!).and_raise(ActiveRecord::ActiveRecordError)

        expect { feed.fetch_and_save! }.to raise_error(Feed::FeedError)
      end
    end
  end
end
